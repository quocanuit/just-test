#!/bin/bash

set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="argocd"

echo "Installing ArgoCD..."

helm repo add argo https://argoproj.github.io/argo-helm

helm upgrade --install argo-cd argo/argo-cd \
    --version 9.0.0 \
    --namespace $NAMESPACE \
    -f "$ROOT/argocd-values.yaml" \
    --wait \
    --timeout 10m

echo "ArgoCD installed!"

echo "Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argo-cd-argocd-server -n $NAMESPACE

echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Logging into ArgoCD..."
argocd login argo-cd-argocd-server.$NAMESPACE.svc.cluster.local --username admin --password "$ARGOCD_PASSWORD" --insecure

echo "Adding repository to ArgoCD..."
argocd repo add https://github.com/quocanuit/just-test.git --type git

echo "ArgoCD setup complete!"
