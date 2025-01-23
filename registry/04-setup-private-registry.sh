#!/bin/bash

# variables
BASIC_AUTH_USER=admin
BASIC_AUTH_PASSWORD=admin

# create auth, data folder
mkdir -p /home/ubuntu/efs/devops-swarm-cluster-and-observability/registry/data
mkdir -p /home/ubuntu/efs/devops-swarm-cluster-and-observability/registry/auth

# create basic auth user
docker run --rm --entrypoint htpasswd httpd:2 -Bbn $BASIC_AUTH_USER $BASIC_AUTH_PASSWORD > /home/ubuntu/efs/devops-swarm-cluster-and-observability/registry/auth/htpasswd