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
