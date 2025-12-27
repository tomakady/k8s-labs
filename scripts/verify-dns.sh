#!/bin/bash
# scripts/verify-dns.sh

INGRESS_HOST=$(kubectl get ingress argocd-server -n argo-cd -o jsonpath='{.spec.rules[0].host}')
LB_HOSTNAME=$(kubectl get ingress argocd-server -n argo-cd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Verifying DNS record for $INGRESS_HOST..."
aws route53 list-resource-record-sets \
  --hosted-zone-id Z0314813274VWO3I28JJY \
  --query "ResourceRecordSets[?Name=='${INGRESS_HOST}.']" \
  --output table

echo ""
echo "Expected load balancer: $LB_HOSTNAME"