#!/bin/bash

# verify docker registry work
docker login localhost:5000
docker pull nginx:latest
docker tag nginx:latest localhost:5000/nginx:latest
docker push localhost:5000/nginx:latest

docker stack deploy --with-registry-auth -c /home/ubuntu/efs/devops-swarm-cluster-and-observability/registry/nginx-stack.yml nginx
docker stack ps nginx