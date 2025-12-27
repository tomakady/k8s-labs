variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.34"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}