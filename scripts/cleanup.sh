#!/bin/bash

# Delete Helm releases
helm uninstall argocd --namespace argo-cd
helm uninstall external-dns --namespace external-dns
helm uninstall nginx-ingress --namespace nginx-ingress
helm uninstall cert-manager --namespace cert-manager

# Delete ArgoCD related CRDs
kubectl delete crd applications.argoproj.io
kubectl delete crd applicationsets.argoproj.io
kubectl delete crd argocds.argoproj.io
kubectl delete crd appprojects.argoproj.io
kubectl delete crd applications.argoproj.io
kubectl delete crd applicationsets.argoproj.io
kubectl delete crd argocds.argoproj.io
kubectl delete crd appprojects.argoproj.io

# Delete Cert-Manager related CRDs
kubectl delete crd clusterissuers.cert-manager.io
kubectl delete crd issuers.cert-manager.io
kubectl delete crd certificates.cert-manager.io
kubectl delete crd orders.cert-manager.io
kubectl delete crd challenges.cert-manager.io
kubectl delete crd certificaterequests.cert-manager.io
kubectl delete crd certificates.cert-manager.io
kubectl delete crd orders.cert-manager.io

# Delete namespaces if no longer needed
kubectl delete namespace argo-cd
kubectl delete namespace external-dns
kubectl delete namespace nginx-ingress
kubectl delete namespace cert-manager