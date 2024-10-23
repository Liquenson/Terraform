output "lb_dns_name" {
  value       = aws_lb.myweb.dns_name
  description = "The DNS name of the load balancer"
}