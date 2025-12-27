#!/bin/bash
# scripts/check-external-dns.sh

echo "Checking External-DNS status..."
kubectl get pods -n external-dns
echo ""
echo "Checking Service Account annotation..."
kubectl get sa external-dns -n external-dns -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}'
echo ""
echo "Checking External-DNS logs..."
kubectl logs -n external-dns -l app.kubernetes.io/name=external-dns --tail=10