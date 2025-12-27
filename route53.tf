data "aws_route53_zone" "labs" {
  zone_id = "Z0314813274VWO3I28JJY"
}

output "labs_zone_id" {
  value       = data.aws_route53_zone.labs.zone_id
  description = "Hosted zone ID for labs.tomakady.com"
}

output "labs_zone_name_servers" {
  value       = data.aws_route53_zone.labs.name_servers
  description = "Name servers for labs subdomain delegation"
}