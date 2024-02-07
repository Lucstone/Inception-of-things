#!/bin/sh

curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip=192.168.56.110 \
  --flannel-iface=eth1 \

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  echo "Waiting for token..."
  sleep 1
done
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/k3s-node-token

while ! kubectl get pods -n kube-system 2>/dev/null | grep -q 'Running'; do
  echo "Waiting for k3s to be ready..."
  sleep 3
done

for app in app1 app2 app3; do
  echo "Deploying $app..."
  kubectl apply -f /vagrant/confs/$app
    kubectl create configmap $app-index --from-file=index.html=/vagrant/confs/$app/$app-index.html 2>/dev/null
done

echo "Now applying the ingress..."
sudo kubectl apply -f /vagrant/confs/app-ingress.yaml

echo "Done!"