<<<<<<< HEAD
# EKS Lab - Kubernetes Cluster with ArgoCD

This repository contains Terraform configurations and Kubernetes manifests for deploying an EKS cluster with ArgoCD, NGINX Ingress, Cert-Manager, and ExternalDNS.

## Architecture

- **EKS Cluster**: Managed Kubernetes cluster on AWS
- **ArgoCD**: GitOps continuous delivery tool
- **NGINX Ingress Controller**: Load balancer and ingress management
- **Cert-Manager**: Automatic TLS certificate management with Let's Encrypt
- **ExternalDNS**: Automatic DNS record management in Route53
- **VPC Endpoints**: Cost optimization for EKS API calls

## Prerequisites

Before deploying, ensure you have:

- AWS CLI installed and configured
- Terraform >= 1.0
- kubectl installed
- helm installed
- jq, dig (dnsutils) installed
- Access to AWS account with appropriate permissions
- Route53 hosted zone for your subdomain (created by Terraform)
- DNS delegation configured in parent domain (see [DNS Setup Guide](docs/DNS_SETUP.md))

## Quick Start

### 1. Pre-Deployment Checks

Run the pre-deployment validation script to ensure everything is configured correctly:

```bash
./scripts/pre-deploy-check.sh
```

This will check:
- AWS credentials
- Route53 hosted zone
- DNS delegation
- EKS cluster status
- Required tools

### 2. Configure DNS Delegation

**IMPORTANT**: Before deploying, you must configure DNS delegation in your parent domain.

1. Get the name servers from Terraform:
   ```bash
   terraform output labs_zone_name_servers
   ```

2. Add NS records in your parent domain (`tomakady.com`) pointing to these name servers.

See [DNS Setup Guide](docs/DNS_SETUP.md) for detailed instructions.

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

This will create:
- VPC with public/private subnets
- EKS cluster with managed node groups
- VPC endpoints for cost optimization
- IAM roles and Pod Identity associations
- Helm releases (nginx-ingress, cert-manager, external-dns, argocd)
- ClusterIssuer for Let's Encrypt
- ArgoCD ingress with TLS

### 4. Post-Deployment Verification

After deployment, verify everything is working:

```bash
./scripts/post-deploy-verify.sh
```

This will check:
- All helm releases are deployed
- Pod Identity associations are active
- ClusterIssuer is ready
- Certificates are issued
- DNS records are created
- HTTPS is working

### 5. Access ArgoCD

Once deployment is complete and verification passes:

1. Get the ArgoCD admin password:
   ```bash
   kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

2. Access ArgoCD UI:
   - URL: `https://argocd.labs.tomakady.com`
   - Username: `admin`
   - Password: (from step 1)

## Scripts

### Pre-Deployment Check
```bash
./scripts/pre-deploy-check.sh
```
Validates AWS credentials, Route53 zone, DNS delegation, and cluster connectivity before deployment.

### Post-Deployment Verification
```bash
./scripts/post-deploy-verify.sh
```
Comprehensive verification of all deployed components, certificates, DNS records, and HTTPS connectivity.

### Health Check
```bash
./scripts/health-check.sh
```
Quick health check for ongoing monitoring. Checks pod status, certificate expiration, DNS resolution, and HTTPS endpoints.

### Route53 DNS Resolver
```bash
# Using defaults
./scripts/route53-resolve.sh

# Custom options
./scripts/route53-resolve.sh -f myapp.labs.tomakady.com -n default -i myapp-ingress
```
Manually create or update Route53 A/AAAA alias records for ingress LoadBalancers.

## Configuration

### Variables

Edit `variables.tf` or set environment variables:

- `cluster_version`: Kubernetes version (default: "1.34")
- `region`: AWS region (default: "eu-west-2")

### Domain Configuration

Update `locals.tf` to change the domain:

```hcl
locals {
  domain = "labs.tomakady.com"  # Change this
  # ...
}
```

### Cert-Manager Email

Update `cert-manager-issuer.tf` to change the Let's Encrypt email:

```hcl
email = "your-email@example.com"
```

## Troubleshooting

### DNS Issues

**Problem**: Domain doesn't resolve or shows "Non-existent domain"

**Solutions**:
1. Verify DNS delegation in parent zone (see [DNS Setup Guide](docs/DNS_SETUP.md))
2. Flush local DNS cache: `ipconfig /flushdns` (Windows) or `sudo dscacheutil -flushcache` (macOS)
3. Use public DNS resolvers temporarily (8.8.8.8, 1.1.1.1)
4. Wait for DNS propagation (can take up to 48 hours)

### Certificate Issues

**Problem**: Certificate stuck in "Pending" or not ready

**Solutions**:
1. Check ClusterIssuer exists: `kubectl get clusterissuer issuer`
2. Check cert-manager Pod Identity: `kubectl get pods -n cert-manager`
3. Check certificate request: `kubectl describe certificaterequest -n argo-cd`
4. Verify Route53 permissions for cert-manager IAM role

### HTTPS Issues

**Problem**: "ERR_SSL_PROTOCOL_ERROR" or "invalid response"

**Solutions**:
1. Verify certificate is ready: `kubectl get certificate -n argo-cd argocd-tls`
2. Check ingress TLS configuration: `kubectl get ingress -n argo-cd argocd-server -o yaml`
3. Verify nginx controller HTTPS port: `kubectl get svc -n nginx-ingress`
4. Check NLB backend protocol is set to TCP (not HTTP)

### ExternalDNS Issues

**Problem**: DNS records not created automatically

**Solutions**:
1. Check ExternalDNS pod is running: `kubectl get pods -n external-dns`
2. Check Pod Identity association: `terraform output external_dns_role_arn`
3. Check ExternalDNS logs: `kubectl logs -n external-dns -l app.kubernetes.io/name=external-dns`
4. Verify ingress has ExternalDNS annotation: `external-dns.alpha.kubernetes.io/hostname`

### Pod Identity Issues

**Problem**: Pods can't assume IAM roles

**Solutions**:
1. Verify Pod Identity addon is installed: `aws eks describe-addon --cluster-name eks-lab --addon-name eks-pod-identity-agent`
2. Check Pod Identity associations: `kubectl get pods -n cert-manager -o yaml | grep -i identity`
3. Verify IAM roles exist: `terraform output cert_manager_role_arn`

## Common Commands

```bash
# Get cluster kubeconfig
aws eks update-kubeconfig --name eks-lab --region eu-west-2

# Check all helm releases
helm list -A

# Check certificate status
kubectl get certificate -A

# Check ingress status
kubectl get ingress -A

# Check DNS records in Route53
aws route53 list-resource-record-sets --hosted-zone-id Z0314813274VWO3I28JJY

# View ArgoCD admin password
kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Restart cert-manager (if needed)
kubectl rollout restart deploy/cert-manager -n cert-manager
```

## File Structure

```
.
├── cert-manager-issuer.tf    # ClusterIssuer for Let's Encrypt
├── argocd-ingress.tf         # ArgoCD ingress with TLS
├── eks.tf                    # EKS cluster configuration
├── helm.tf                   # Helm releases
├── iam.tf                    # IAM roles and Pod Identity
├── route53.tf                # Route53 data sources
├── vpc.tf                    # VPC and networking
├── helm-values/              # Helm chart values
│   ├── argocd.yaml
│   ├── cert-manager.yaml
│   ├── external-dns.yaml
│   └── nginx-ingress.yaml
├── scripts/                  # Automation scripts
│   ├── pre-deploy-check.sh
│   ├── post-deploy-verify.sh
│   ├── health-check.sh
│   └── route53-resolve.sh
└── docs/                     # Documentation
    └── DNS_SETUP.md
```

## Dependencies

The deployment follows this dependency order:

1. EKS Cluster
2. Pod Identity Addon
3. Pod Identity Associations (external-dns, cert-manager)
4. Helm Releases (nginx, cert-manager, external-dns)
5. ClusterIssuer (depends on cert-manager + Pod Identity)
6. ArgoCD Helm Release
7. ArgoCD Ingress (depends on ClusterIssuer + nginx)

## Cost Optimization

This setup includes VPC endpoints to reduce EKS API call costs:
- ECR API and DKR (container registry)
- STS (security token service)
- CloudWatch Logs
- S3 (gateway endpoint)

## Security Notes

- Pod Identity is used instead of IRSA for better security and simplicity
- TLS certificates are automatically managed by Cert-Manager
- All ingress traffic is forced to HTTPS
- VPC endpoints keep traffic within AWS network

## Additional Resources

- [DNS Setup Guide](docs/DNS_SETUP.md) - Detailed DNS delegation instructions
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [ExternalDNS Documentation](https://github.com/kubernetes-sigs/external-dns)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the [DNS Setup Guide](docs/DNS_SETUP.md)
3. Run the verification scripts to diagnose issues
4. Check Kubernetes and AWS logs
=======

>>>>>>> 1531060 (messing around with k8s after trying to follow a tutorial series. lots of things deprecated and im new to k8s so hey lets see what we can do. nothing works but its ok lol)
