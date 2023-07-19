#!/usr/bin/env bash

## KIND
## -----------------

# Start the management cluster
if ! kind get clusters | grep -q "management"; then
  kind create cluster --name management
fi

# Set the current context
kubectl config use-context kind-management

## ARGOCD
## -----------------

# Create the ArgoCD namespace
kubectl create namespace argocd

# Add the ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm

# Install ArgoCD helm chart
helm upgrade --install argocd argo/argo-cd \
  --version 5.16.14 \
  --set crds.install=true \
  --namespace argocd

# Wait for resources to post
sleep 10

while [[ $(kubectl get pods -n argocd | grep -c "1/1") -lt 7 ]]; do
  echo "░ Waiting for ArgoCD server to be ready..."
  sleep 5
done

## DEPLOY
## -----------------

ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Forward the ArgoCD server port
kubectl port-forward svc/argocd-server -n argocd 8080:80 & echo $! > argocd.pid

# Login to ArgoCD
argocd login localhost:8080 \
  --username admin \
  --password $ARGO_PASSWORD \
  --insecure

# Add the delivery cluster
argocd cluster add kind-delivery --name delivery -y

cd ./bootstrap/delivery
./apply.sh
cd -

## CLEANUP
## -----------------

kill $(cat argocd.pid)
rm argocd.pid


## OUTPUTS
## -----------------

ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "░ To access the ArgoCD UI, first run the following        "
echo "░ command in a new terminal window:                       "
echo "░"
echo "░ kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo "░"
echo "░ Then open the following URL in your browser:  "
echo "░"
echo "░ ArgoCD UI: http://localhost:8080              "
echo "░ ArgoCD Username: admin                        "
echo "░ ArgoCD Password: $ARGO_PASSWORD               "
