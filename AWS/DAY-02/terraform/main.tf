

# creating aws_key_pair

resource "aws_key_pair" "my_key_pair" {
  key_name = "my_dev_key"
  public_key = file("C:\\Users\\harik\\.ssh\\id_ed25519.pub")
}

resource "aws_default_vpc" "my_default_vpc" {
  
}


resource "aws_security_group" "my_aws_security_gp" {
  name = "my-sg"
  vpc_id = aws_default_vpc.my_default_vpc.id
  description = "my security grup"

  ingress {
    from_port=22
    to_port = 22 
    description = "open ssh"
    cidr_blocks = ["0.0.0.0/0"]
    protocol="tcp" 
  }

  ingress{
    from_port = 80
    to_port = 80
    description = "open HTTP"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    description = "access everything from server"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "My Security-G"
  }

}


resource "aws_instance" "my_aws_tf_instance" {
  key_name = aws_key_pair.my_key_pair.key_name
  ami = "ami-0b6c6ebed2801a5cb"
  security_groups = [aws_security_group.my_aws_security_gp.name]
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  instance_type = "t3.micro"
  tags = {
    Name = "my_tf_ec2"
  }

}
