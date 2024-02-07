#!/bin/sh
sudo apk update && apk add net-tools
if [ $(hostname) = "eleleuxS" ]
then
    curl -sfL https://get.k3s.io | sh -s - server --node-ip=192.168.56.110 --flannel-iface=eth1
    while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
          echo "Waiting for node-token to be created..."
          sleep 1
    done    
    sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/k3s-node-token
else
    
    while [ ! -f /vagrant/k3s-node-token ]; do
        echo "Waiting for token..."
        sleep 1
    done
    echo "Token found! Joining the cluster..."
    curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$(cat /vagrant/k3s-node-token) sh -s agent --node-ip=192.168.56.111
fi