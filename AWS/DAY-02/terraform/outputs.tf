output "my_ec2_dns" {
  value = aws_instance.my_aws_tf_instance.public_dns
}

output "my_ec2_ip" {
  value = aws_instance.my_aws_tf_instance.public_ip
}