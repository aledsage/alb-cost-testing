resource "aws_security_group" "alb_sg" {
  name        = "alb"
  description = "Web server with direct access"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["45.149.252.2/32", "5.148.153.61/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.public.0.id,
    aws_subnet.public.1.id
  ]
  security_groups    = [
    aws_security_group.alb_sg.id
  ]

  depends_on = [aws_security_group.alb_sg]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances_tg.arn
  }
}

resource "aws_lb_target_group" "instances_tg" {
  name        = "alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "webserver" {
  target_group_arn = aws_lb_target_group.instances_tg.arn
  target_id        = aws_instance.webserver.id
  port             = 80
}
