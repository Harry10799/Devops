output "app_url" {
  value = "http://${aws_instance.my_todo_ec2.public_ip}"
}

output "rds_url" {
  value = "${aws_db_instance.rds_instance.endpoint}"
}