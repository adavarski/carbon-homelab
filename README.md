# KinD+ArgoCD: multicluster playground

> **Table of Contents**
> * [Introduction](#introduction)
> * [Prerequisites](#prerequisites)
> * [Getting started](#getting-started)
>   * [Delivery cluster](#delivery-cluster)
>   * [Repository access](#repository-access)
>   * [Accessing the UIs](#accessing-the-uis)
>   * [Custom resources (CRDs)](#custom-resources)
> * [Using the CLI](#using-the-cli)

## Introduction

Carbon-homelab is a sandbox for deploying [Prometheus](https://prometheus.io), [Grafana](https://grafana.com), [Loki](https://grafana.com/oss/loki/), etc. apps to K8s with [ArgoCD](https://argoproj.github.io/cd/).

## Prerequisites

- [Docker](https://www.docker.com/)
- [Kind](https://kind.sigs.k8s.io/) 
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 
- [Helm](https://helm.sh/)
- [ArgoCD](https://argoproj.github.io/argo-cd/getting_started/) 

## Getting started

1. Create a fork of this repo, and clone it to your local machine.
2. Open a terminal on the cloned directory and run `./homelab-carbon init`.
3. When you're done, run `./homelab-carbon kill` to tear down the clusters.

`carbon-homelab` will create local Kind clusters for management and delivery, and deploy ArgoCD to the management cluster. It will also deploy Prometheus, Grafana, Loki, etc. to the delivery cluster.

### Delivery cluster

ArgoCD needs access to the delivery cluster, so it can deploy the applications. To do this, homelab-carbon uses a kind [config file](https://kind.sigs.k8s.io/docs/user/configuration/) to create a cluster with an `apiServerAddress` set to the host machine's IP address.

You can set it manually IP in the `delivery/cluster.yaml` file.

### Repository access

ArgoCD needs access to the repo. GitOps works by pulling the manifests from a git repository, and applying them to the cluster. 

### Accessing the UIs

Once the clusters are up, you can access the UIs. You'll need to forward the ports for each service. First, set the context for the cluster you want to access:

```bash
$ kubectl config use-context kind-{delivery|management}
```

Then, forward the ports (in separate terminals):

```bash
$ kubectl port-forward svc/{service} -n {namespace} {ports}
```

List of values to pass into `kubectl port-forward`:

| Service | Namespace | Ports |
| --- | --- | --- |
| argocd-server | argocd | `8080:80` |
| grafana | monitoring | `3000:80`    |
| prometheus | monitoring | `9090:9090` |

Example (Grafana & ArgoCD UI): 
```
$ kubectl config use-context kind-delivery
$ kubectl get svc --all-namespaces
NAMESPACE     NAME                                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
default       kubernetes                                           ClusterIP   10.96.0.1       <none>        443/TCP                        30m
element       element-elementweb                                   ClusterIP   10.96.82.61     <none>        80/TCP                         27m
excalidraw    excalidraw                                           ClusterIP   10.96.244.152   <none>        80/TCP                         27m
kube-system   kube-dns                                             ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP         30m
kube-system   monitoring-kube-prometheus-coredns                   ClusterIP   None            <none>        9153/TCP                       27m
kube-system   monitoring-kube-prometheus-kube-controller-manager   ClusterIP   None            <none>        10257/TCP                      27m
kube-system   monitoring-kube-prometheus-kube-etcd                 ClusterIP   None            <none>        2381/TCP                       27m
kube-system   monitoring-kube-prometheus-kube-proxy                ClusterIP   None            <none>        10249/TCP                      27m
kube-system   monitoring-kube-prometheus-kube-scheduler            ClusterIP   None            <none>        10259/TCP                      27m
kube-system   monitoring-kube-prometheus-kubelet                   ClusterIP   None            <none>        10250/TCP,10255/TCP,4194/TCP   26m
loki          loki                                                 ClusterIP   10.96.67.193    <none>        3100/TCP                       25m
loki          loki-headless                                        ClusterIP   None            <none>        3100/TCP                       25m
loki          loki-memberlist                                      ClusterIP   None            <none>        7946/TCP                       25m
monitoring    alertmanager-operated                                ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP     26m
monitoring    monitoring-grafana                                   ClusterIP   10.96.182.211   <none>        80/TCP                         27m
monitoring    monitoring-kube-prometheus-alertmanager              ClusterIP   10.96.23.70     <none>        9093/TCP                       27m
monitoring    monitoring-kube-prometheus-operator                  ClusterIP   10.96.252.185   <none>        443/TCP                        27m
monitoring    monitoring-kube-prometheus-prometheus                ClusterIP   10.96.105.190   <none>        9090/TCP                       27m
monitoring    monitoring-kube-state-metrics                        ClusterIP   10.96.209.43    <none>        8080/TCP                       27m
monitoring    monitoring-prometheus-node-exporter                  ClusterIP   10.96.207.141   <none>        9100/TCP                       27m
monitoring    prometheus-operated                                  ClusterIP   None            <none>        9090/TCP                       26m
speedtest     speedtest-speedtest-exporter                         ClusterIP   10.96.130.248   <none>        9798/TCP                       24m

$ kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
$ kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

$ kubectl config use-context kind-managemant
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
$ kubectl port-forward svc/argocd-server -n argocd 8080:80 (Note: carbon-homelab outputs argocd admin password)

```

### Screenshots:

<img src="screenshots/ArgoCD-UI-Clusters.png?raw=true" width="1000">

<img src="screenshots/ArgoCD-UI-Apps.png?raw=true" width="1000">

<img src="screenshots/Grafana-UI.png?raw=true" width="1000">


### Custom resources (CRDs)

When deploying a Helm application Argo CD is using Helm only as a template mechanism. It runs helm template and then deploys the resulting manifests on the cluster instead of doing helm install. This means that you cannot use any Helm command to view/verify the application. It is fully managed by Argo CD. Note that Argo CD supports natively some capabilities that you might miss in Helm (such as the history and rollback commands).

Ref: https://argo-cd.readthedocs.io/en/stable/user-guide/helm/ && https://argo-cd.readthedocs.io/en/stable/faq/#after-deploying-my-helm-application-with-argo-cd-i-cannot-see-it-with-helm-ls-and-other-helm-commands

Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Template/


## Using the CLI

`carbon-homelab` provides a cli to help you raise and lower the stack. It's a simple wrapper around `kind`, `kubectl`, and `helm`, so you can use those tools directly if you prefer.

| Command | Description |
| --- | --- |
| `./homelab-carbon init` | Create clusters and deploy apps. |
| `./homelab-carbon kill` | Tear down clusters. |
| `./homelab-carbon help` | Print help text. |













