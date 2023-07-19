#!/usr/bin/env bash

## BOOTSTRAP
## -----------------

# get the ip address of the host
host_ip=192.168.1.100

# if host_ip is empty, use en1
if [ -z "$host_ip" ]; then
  host_ip=192.168.1.100
fi

# update cluster server address
sed "s/apiServerAddress: .*$/apiServerAddress: ${host_ip}/" cluster.yaml

## KIND
## -----------------

# Start the delivery cluster
if ! kind get clusters | grep -q "delivery"; then
  kind create cluster --name delivery --config cluster.yaml
fi
