output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = local.region
}

output "external_dns_role_arn" {
  description = "IAM role ARN for external-dns"
  value       = aws_iam_role.external_dns_pod_identity.arn
}