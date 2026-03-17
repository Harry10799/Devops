#vpc

resource "aws_vpc" "my_vpc" {
  cidr_block = var.two_tier_vpc
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "my_public_subnet_1a" {
  cidr_block = var.my_public_subnet1a
  vpc_id = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_subnet" "my_private_subnet_1a" {
  cidr_block = var.my_private_subnet1a
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "my_private_subnet_2a" {
  cidr_block = var.my_private_subnet2a
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = "us-east-1b"
}


#igw

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

#public route

resource "aws_route_table" "my_rb_public" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}


# route association

resource "aws_route_table_association" "route_association" {
    route_table_id = aws_route_table.my_rb_public.id
    subnet_id = aws_subnet.my_public_subnet_1a.id
}


# security grps


resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name = "web-sg"

  ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    description = "ssh"
  }

  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# sg for rds

resource "aws_security_group" "rds-sg" {
    vpc_id = aws_vpc.my_vpc.id
    name = "rds_sg"

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [ aws_security_group.web_sg.id ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  
}

resource "aws_db_subnet_group" "db_subnet" {
  name = "db-subnet-grp"
  subnet_ids = [aws_subnet.my_private_subnet_1a.id, aws_subnet.my_private_subnet_2a.id]
}


resource "aws_db_instance" "rds_instance" {
  identifier = "todo-app"
  instance_class = "db.t3.micro"
  engine = "mysql"
  engine_version = "8.0"
  allocated_storage = 20
  db_name = "todoapp"
  username = "admin"
  password = "SuperSecret123!"
  skip_final_snapshot = true
  publicly_accessible = false
  multi_az = false
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
}

resource "aws_instance" "my_todo_ec2" {
  ami = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]
  subnet_id = aws_subnet.my_public_subnet_1a.id 
  associate_public_ip_address = true
  user_data = <<-EOF
#!/bin/bash -xe
apt update -y
apt install -y nodejs npm
mkdir -p /app && cd /app

cat > /app/app.js <<'EOT'
const express = require('express');
const mysql = require('mysql2');
const app = express();
app.use(express.urlencoded({ extended: true }));

const pool = mysql.createPool({
  host: '${aws_db_instance.rds_instance.endpoint}',
  user: 'admin',
  password: 'SuperSecret123!',
  database: 'todoapp',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

pool.query('CREATE TABLE IF NOT EXISTS tasks (id INT AUTO_INCREMENT PRIMARY KEY, task VARCHAR(255) NOT NULL)', err => {
  if (err) console.log('DB schema init error:', err);
  else console.log('DB schema ready');
});

app.get('/', (req, res) => {
  pool.query('SELECT * FROM tasks', (err, results) => {
    if (err) return res.send('Error: ' + err);
    let html = '<h1>Simple To-Do App</h1><ul>';
    results.forEach(r => { html += '<li>' + r.task + '</li>'; });
    html += '</ul>';
    html += '<form method="POST" action="/add"><input type="text" name="task" placeholder="Add task..." required><button>Add</button></form>';
    res.send(html);
  });
});

app.post('/add', (req, res) => {
  const task = req.body.task;
  if (task) {
    pool.query('INSERT INTO tasks (task) VALUES (?)', [task], err => {
      if (err) console.log('Insert error:', err);
      res.redirect('/');
    });
  } else {
    res.redirect('/');
  }
});

app.listen(80, () => console.log('App listening on port 80'));
EOT

cat > /etc/systemd/system/todo-app.service <<'SERVICE'
[Unit]
Description=ToDo App Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/app
ExecStart=/usr/bin/node /app/app.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
SERVICE

cd /app
npm init -y
npm install express mysql2

systemctl daemon-reload
systemctl enable --now todo-app
EOF
    tags = {
      Name = "ToDo-app"
    }
}


