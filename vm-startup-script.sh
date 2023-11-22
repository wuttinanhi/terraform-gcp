#!/bin/bash

# Install Docker
curl -fsSL https://get.docker.com | sh

# test run docker info
docker info

# Create and enable a user 'docker' with password 'docker'
# useradd -m -p $(openssl passwd -1 "docker") -s /bin/bash docker
# usermod -aG docker docker

# create user 'docker' with password '@Docker12345'
sudo useradd docker -p $(openssl passwd -1 "@Docker12345") -g docker

# change password of docker user to @Docker12345
sudo usermod --password $(echo @Docker12345 | openssl passwd -1 -stdin) docker

# Uncomment the PasswordAuthentication line (if it exists) and set it to yes
sudo sed -i 's/#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart the SSH service to apply the changes
sudo systemctl restart ssh

# run simple nginx container
docker run -d -p 80:80 nginx
