module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24.2"

  cluster_name    = local.name
  cluster_version = "1.34"

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_addons = {
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  enable_irsa = false

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    default = {
      version      = "1.34"
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = local.tags
}