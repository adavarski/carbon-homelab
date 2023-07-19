#!/usr/bin/env sh

VALUES="values.yaml"

helm template \
    --include-crds \
    --namespace argocd \
    --values "${VALUES}" \
    argocd . \
    | kubectl delete -n argocd -f -
