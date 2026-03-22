resource "aws_lb" "my_lb" {
    name = "my-http-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.my_lb_sg.id ]
    subnets = [aws_subnet.my_lb_public_subnet_1.id, aws_subnet.my_lb_public_subnet_2.id ]

}

resource "aws_lb_target_group" "my_lb_tg" {
  name = "my-lb-target-grup"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_lb_vpc.id 
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_lb_tg.arn
    type = "forward"
  }
}