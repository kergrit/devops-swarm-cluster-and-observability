#!/bin/bash

# build docker image 
docker build -t localhost:5000/ftp-server .

# push image to private registry
docker push localhost:5000/ftp-server

# deploy ftp-server stack
docker stack deploy --with-registry-auth -c /home/ubuntu/efs/devops-swarm-cluster-and-observability/ftp/ftp-stack.yml ftp
docker stack ps ftp