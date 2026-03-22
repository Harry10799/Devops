resource "aws_security_group" "my_lb_sg" {
  name = "my_loadbalancer-sg"
  vpc_id = aws_vpc.my_lb_vpc.id

  ingress {

    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ssh"
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow http"
  }

  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow internet"

  }

}


resource "aws_launch_template" "my_lb_launch_temp" {
  name_prefix = "http-server-"
  image_id = var.ami_id
  instance_type = "t3.micro"
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [ aws_security_group.my_lb_sg.id ]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello world from the - $(hostname)</h1>" | sudo tee /var/www/html/index.html
EOF
  )

}

resource "aws_autoscaling_group" "my_lb_autoscale" {
  desired_capacity = 2
  min_size = 2
  max_size = 3
  vpc_zone_identifier = [ aws_subnet.my_lb_public_subnet_1.id, aws_subnet.my_lb_public_subnet_2.id ]
  target_group_arns = [ aws_lb_target_group.my_lb_tg.arn ]

  launch_template {
    id = aws_launch_template.my_lb_launch_temp.id
  }
}




