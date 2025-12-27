#!/bin/bash
# scripts/post-apply-check.sh

echo "=== Checking External-DNS ==="
kubectl get pods -n external-dns
echo ""

echo "=== Checking Service Account Role ARN ==="
ROLE_ARN=$(kubectl get sa external-dns -n external-dns -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}')
if [ -z "$ROLE_ARN" ]; then
  echo "❌ ERROR: Role ARN is empty!"
else
  echo "✅ Role ARN: $ROLE_ARN"
fi
echo ""

echo "=== Checking Ingress ==="
kubectl get ingress argocd-server -n argo-cd
echo ""

echo "=== Waiting 2 minutes for External-DNS to sync... ==="
sleep 120

echo "=== Checking DNS Records ==="
aws route53 list-resource-record-sets \
  --hosted-zone-id Z0314813274VWO3I28JJY \
  --query "ResourceRecordSets[?Name=='argocd.labs.tomakady.com.']" \
  --output table
echo ""

echo "=== Testing DNS Resolution ==="
nslookup argocd.labs.tomakady.com || echo "DNS not resolving yet - may need to wait longer or create manually"