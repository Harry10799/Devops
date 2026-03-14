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


resource "local_file" "sample_file" {
  content = var.new_var
  filename = var.filename
}




variable "files" {
    default = ["file1.txt","file2.txt","file3.txt"]
}


resource "local_file" "eg" {
  count = 3
  filename = "file_${count.index}.txt"
  content = "Tf example"
}


resource "local_file" "file" {
    for_each = toset(var.files)
    filename = each.value
    content = "tf"
}

variable "environment" {
  default = "DEV"
}

locals {
  message=var.environment=="DEV" ? "DEVELOPMENT" : "PROD"
}

resource "local_file" "file_new" {
  filename = "newtext.txt"
  content = local.message
}