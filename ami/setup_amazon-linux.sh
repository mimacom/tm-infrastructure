#!/bin/sh
set -e

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Setup git"
sudo yum install -y git

echo "[INFO] [${SCRIPT}] Setup docker"
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "[INFO] [${SCRIPT}] Setup dnsmasq"
sudo yum install -y dnsmasq
sudo chkconfig --level 345 dnsmasq on

sudo mkdir -p /etc/dnsmasq.d
echo "server=/consul/127.0.0.1#8600" | sudo tee /etc/dnsmasq.d/10-consul
echo "prepend domain-name-servers 127.0.0.1;" | sudo tee -a /etc/dhcp/dhclient.conf
