output "webserver_ip" {
  value = aws_instance.webserver.public_ip
}
output "alb_dns" {
  value = aws_lb.lb.dns_name
}
