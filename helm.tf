resource "helm_release" "nginx" {
  name = "nginx-ingress"

  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  timeout    = 300

  create_namespace = true
  namespace        = "nginx-ingress"

  values = [
    "${file("helm-values/nginx-ingress.yaml")}"
  ]

  set = [
    {
      name  = "controller.ingressClassResource.name"
      value = "nginx"
    },
    {
      name  = "controller.ingressClassResource.enabled"
      value = "true"
    },
    {
      name  = "controller.service.type"
      value = "LoadBalancer"
    }
  ]

  depends_on = [module.eks]

  lifecycle {
    create_before_destroy = false
  }
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "startupapicheck.enabled"
      value = "false"
    }
  ]

  values = [
    "${file("helm-values/cert-manager.yaml")}"
  ]

  depends_on = [module.eks]

}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.18.0"


  create_namespace = true
  namespace        = "external-dns"

  values = [
    templatefile("${path.module}/helm-values/external-dns.yaml", {
      role_arn = aws_iam_role.external_dns_pod_identity.arn
    })
  ]

  set = [
    {
      name  = "image.repository"
      value = "registry.k8s.io/external-dns/external-dns"
    },
    {
      name  = "image.tag"
      value = "v0.19.0"
    }
  ]

  depends_on = [
    module.eks,
    aws_eks_pod_identity_association.external_dns
  ]
}

resource "helm_release" "argocd_deploy" {
  name          = "argocd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  timeout       = 300
  wait          = true
  wait_for_jobs = true

  namespace        = "argo-cd"
  create_namespace = true

  values = [
    "${file("helm-values/argocd.yaml")}"
  ]

  depends_on = [module.eks]

}