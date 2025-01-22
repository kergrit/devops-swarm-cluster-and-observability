#!/bin/bash

# ---------------------------------
# set variable
# ---------------------------------
HOSTNAME=demo-swarm-manager-1
UBUNTU_USER=ubuntu
EFS_DNS_NAME=FILE-SYSTEM-ID.efs.ap-southeast-1.amazonaws.com
EFS_PATH=/home/ubuntu/efs
PLATFORM="linux-$(uname -m)"
DOCKER_COMPOSE_VERSION=2.32.3
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}

# ---------------------------------
# update repo
# ---------------------------------
sudo apt-get update
sudo apt-get upgrade -y

# ---------------------------------
# setup hostname
# ---------------------------------
echo "$HOSTNAME" | sudo tee /etc/hostname; sudo hostname "$HOSTNAME" 

# ---------------------------------
# setup efs
# ---------------------------------
sudo apt-get -y install nfs-common
sudo mkdir $EFS_PATH
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_DNS_NAME:/ $EFS_PATH
echo "$EFS_DNS_NAME:/ $EFS_PATH nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo chown -R $EFS_PATH "$UBUNTU_USER:$UBUNTU_USER"

# ---------------------------------
# setup docker engine
# ---------------------------------
# remove unofficial docker package
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install docker official package
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# install mysql-client nfs-common package
sudo apt-get install mysql-client nfs-common -y

# start docker service and add ubuntu user to docker group
sudo service docker start
sudo usermod -a -G docker $UBUNTU_USER
sudo chmod 666 /var/run/docker.sock

# manual upgrade docker compose
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$PLATFORM -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "alias docker-compose='docker compose'" >>/home/$UBUNTU_USER/.bashrc
source /home/$UBUNTU_USER/.bashrc

echo "======================================================================="
df -h
docker -v
docker compose version
mysql --version
echo "Hostname : $(hostname)"
echo "Platform : $PLATFORM"
echo "Run swarm init with : docker swarm init"
echo "======================================================================="