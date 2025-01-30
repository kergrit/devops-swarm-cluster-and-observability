#!/bin/bash

# build docker image 
docker build -t localhost:5000/ftp-server .

# push image to private registry
docker push localhost:5000/ftp-server