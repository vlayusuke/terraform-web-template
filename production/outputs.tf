output "domain" {
  value = aws_route53_zone.main.name
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}
