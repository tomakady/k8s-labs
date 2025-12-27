#!/bin/bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION