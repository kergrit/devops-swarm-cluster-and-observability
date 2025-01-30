#!/bin/bash
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-gitlab-on-ubuntu
# download install script
sudo apt update
sudo apt install ca-certificates curl openssh-server postfix tzdata perl -y
cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
sudo bash /tmp/script.deb.sh
sudo apt install gitlab-ce -y

# edit configuration
sudo vim /etc/gitlab/gitlab.rb
# external_url 'https://your_domain'
# letsencrypt['contact_emails'] = ['sammy@example.com']

sudo gitlab-ctl reconfigure

# init root password
sudo grep 'Password:' /etc/gitlab/initial_root_password