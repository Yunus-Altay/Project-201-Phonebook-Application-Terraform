output "website_url" {
  value       = "http://${aws_lb.web_server_alb.dns_name}"
  description = "Phonebook Application Load Balancer URL"
}