#!/bin/bash
set -x

# Install necessary dependencies
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get update
sudo apt-get -y -qq install curl wget git vim apt-transport-https ca-certificates
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get -y install python3
sudo apt-get -y install python3-pip
sudo apt-get -y install python3-flask
sudo apt-get install -y systemd
sudo pip install requests
sudo pip install boto3
sudo pip install -U Flask
sudo pip install ec2_metadata

# Setup sudo to allow no-password sudo for "hashicorp" group and adding "terraform" user
sudo groupadd -r hashicorp
sudo useradd -m -s /bin/bash terraform
sudo usermod -a -G hashicorp terraform
sudo cp /etc/sudoers /etc/sudoers.orig
echo "terraform  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/terraform

# Installing SSH key and AWS credentials
sudo mkdir -p /home/terraform/.ssh
sudo chmod 700 /home/terraform/.ssh
sudo cp /tmp/tf-packer.pub /home/terraform/.ssh/authorized_keys
sudo chmod 600 /home/terraform/.ssh/authorized_keys
sudo chown -R terraform /home/terraform/.ssh
sudo mkdir -p /home/terraform/.aws
sudo chmod 700 /home/terraform/.aws
sudo cp /tmp/credentials /home/terraform/.aws
sudo chmod 600 /home/terraform/.aws/credentials
sudo chown -R terraform /home/terraform/.aws

sudo usermod --shell /bin/bash terraform

# Fetch and run simple python http server
git clone https://github.com/vdcn1/terraform-training.git
sudo -H -i -u terraform -- env bash << EOF

whoami
echo ~terraform
echo ""

git clone https://github.com/vdcn1/terraform-training.git
cd ~/terraform-training
git checkout flugel-trial

sudo cp ~/terraform-training/http-server/http.service /etc/systemd/system/

echo "FLASK_APP=/home/terraform/terraform-training/http-server/app.py" | sudo tee -a /etc/environment

sudo systemctl daemon-reload
sudo systemctl enable http.service
sudo systemctl start http.service

EOF
