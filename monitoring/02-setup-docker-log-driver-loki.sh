#!/bin/bash

# Install docker log driver loki
sudo docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions

# Replace default docker log driver to loki
sudo cp daemon.json /etc/docker/daemon.json

# Restart docker engine
sudo service docker restart