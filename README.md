
> **Table of Contents**
> * [Introduction](#introduction)
> * [Prerequisites](#prerequisites)
> * [Getting started](#getting-started)
>   * [Delivery cluster](#delivery-cluster)
>   * [Repository access](#repository-access)
>   * [Accessing the UIs](#accessing-the-uis)
>   * [Custom resources](#custom-resources)
> * [Using the CLI](#using-the-cli)

## Introduction

Titan is a sandbox for deploying [Prometheus](https://prometheus.io), [Thanos](https://thanos.io), and [Grafana](https://grafana.com) to K8s with [ArgoCD](https://argoproj.github.io/cd/).

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

`carbon-homelab` will create local Kind clusters for management and delivery, and deploy ArgoCD to the management cluster. It will also deploy Prometheus, Grafana, Loki to the delivery cluster.

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
| argocd-server | argocd | `8080:443` |
| grafana | monitoring | `3000:3000` |
| prometheus | monitoring | `9090:9090` |

### Custom resources

When deploying a Helm application Argo CD is using Helm only as a template mechanism. It runs helm template and then deploys the resulting manifests on the cluster instead of doing helm install. This means that you cannot use any Helm command to view/verify the application. It is fully managed by Argo CD. Note that Argo CD supports natively some capabilities that you might miss in Helm (such as the history and rollback commands).

## Using the CLI

`carbon-homelab` provides a cli to help you raise and lower the stack. It's a simple wrapper around `kind`, `kubectl`, and `helm`, so you can use those tools directly if you prefer.

| Command | Description |
| --- | --- |
| `./homelab-carbon init` | Create clusters and deploy apps. |
| `./homelab-carbon kill` | Tear down clusters. |
| `./homelab-carbon help` | Print help text. |


### Check delivery cluster
```
$ kubectl config use-context kind-delivery
Switched to context "kind-delivery".
$ kubectl get po --all-namespaces
NAMESPACE            NAME                                                     READY   STATUS      RESTARTS   AGE
descheduler          descheduler-28162094-7cr6x                               0/1     Completed   0          4m23s
descheduler          descheduler-28162096-js876                               0/1     Completed   0          2m25s
descheduler          descheduler-28162098-tlhzj                               0/1     Completed   0          25s
element              element-elementweb-76dbfbfb7-2vjr8                       1/1     Running     0          5m59s
excalidraw           excalidraw-75dd4b8d99-chg5t                              1/1     Running     0          6m1s
kube-system          coredns-565d847f94-2mwq4                                 1/1     Running     0          8m22s
kube-system          coredns-565d847f94-7krvj                                 1/1     Running     0          8m22s
kube-system          etcd-delivery-control-plane                              1/1     Running     0          8m40s
kube-system          kindnet-2lkjq                                            1/1     Running     0          8m23s
kube-system          kube-apiserver-delivery-control-plane                    1/1     Running     0          8m40s
kube-system          kube-controller-manager-delivery-control-plane           1/1     Running     0          8m45s
kube-system          kube-proxy-4gk4l                                         1/1     Running     0          8m23s
kube-system          kube-scheduler-delivery-control-plane                    1/1     Running     0          8m47s
local-path-storage   local-path-provisioner-684f458cdd-c8zdc                  1/1     Running     0          8m22s
loki                 loki-0                                                   1/1     Running     0          3m28s
loki                 loki-promtail-zjjjq                                      1/1     Running     0          3m28s
monitoring           alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running     0          4m57s
monitoring           monitoring-grafana-6ff5b796c8-bm965                      3/3     Running     0          5m48s
monitoring           monitoring-kube-prometheus-operator-6bdcf78689-zsqp4     1/1     Running     0          5m48s
monitoring           monitoring-kube-state-metrics-796557b7d8-5sksd           1/1     Running     0          5m48s
monitoring           monitoring-prometheus-node-exporter-7rzxq                1/1     Running     0          5m48s
monitoring           prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running     0          4m55s
speedtest            speedtest-speedtest-exporter-6d95b8b476-p75wn            1/1     Running     0          3m17s

$ kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
$ kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

```
Screenshots:



