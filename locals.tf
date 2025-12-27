locals {
  name   = "eks-lab"
  domain = "labs.tomakady.com"
  region = "eu-west-2" # London

  tags = {
    Owner       = "tomakady"
    Environment = "sandbox"
    Project     = "EKS Advanced Lab"
  }
}