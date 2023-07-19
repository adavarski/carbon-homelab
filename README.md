<h1 align="center">
  <img src="homelab-carbon.png" width="208" alt=""><br>
  homelab-carbon<br>
</h1>

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

`carbon-homelab` will create local Kind clusters for management and delivery, and deploy ArgoCD to the management cluster. It will also deploy Prometheus, Thanos, and Grafana to the delivery cluster.

### Delivery cluster

ArgoCD needs access to the delivery cluster, so it can deploy the applications. To do this, homelab-carbon uses a kind [config file](https://kind.sigs.k8s.io/docs/user/configuration/) to create a cluster with an `apiServerAddress` set to the host machine's IP address.

You can set it manually IP in the `delivery/cluster.yaml` file.

### Repository access

ArgoCD needs access to the repo. GitOps works by pulling the manifests from a git repository, and applying them to the cluster. If you're happy with the manifests in this repo, you can leave them as-is. If you want to make changes, you'll need to fork the repo, and edit the manifests to point to your fork (use `https`, not `ssh`):

| File | Field |
| --- | --- |
| management/manifests/application.yaml | `repoURL` |
| management/manifests/repository.yaml | `url` |
| delivery/manifests/shared.yaml | `repoURL` |

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
| thanos-query | monitoring | `9090:9090` |

### Custom resources

Helm doesn't support upgrading CRDs in the default `/crds` directory, so homelab-carbon uses [braid](https://github.com/cristibalan/braid) to manage the CRDs for ArgoCD and Prometheus externally. To update the CRDs, run the following:

```bash
$ braid update # and commit the changes
$ kubectl config use-context kind-{management|delivery}
$ kubectl apply -f {management|delivery}/shared/crds
```

## Using the CLI

`carbon-homelab` provides a cli to help you raise and lower the stack. It's a simple wrapper around `kind`, `kubectl`, and `helm`, so you can use those tools directly if you prefer.

| Command | Description |
| --- | --- |
| `./homelab-carbon init` | Create clusters and deploy apps. |
| `./homelab-carbon kill` | Tear down clusters. |
| `./homelab-carbon help` | Print help text. |
