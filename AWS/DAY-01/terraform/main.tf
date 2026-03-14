resource "local_file" "my_first_file" {
  content = "Hello, World!"
  filename = "my_first_file.txt"
}

resource "local_sensitive_file" "new_file" {
    content = "My sensitive file"
    filename = "my_senstitive_file.txt"
}

resource "local_file" "new_content_file" {
    content = file("../aws_vpc_ec2_setup_readme.md")
    filename = "vpc_readme.md"
}


