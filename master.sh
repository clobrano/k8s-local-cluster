#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -eu

FLANNEL_CIDR="10.244.0.0/16"

echo "[+ master] kubeadm init (CIDR:$FLANNEL_CIDR, API SERVER ADV ADDR:$MASTER_IP)"
kubeadm config images pull
kubeadm init \
    --token ${TOKEN} \
    --pod-network-cidr=$FLANNEL_CIDR \
    --apiserver-advertise-address=$MASTER_IP \
    --ignore-preflight-errors=all \
    --v=6

echo "[+ master] configuring root user"
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
# Change the user from root to regular user that is non-root account
sudo chown $(id -u):$(id -g) $HOME/.kube/config

if [[ -f /home/vagrant/.kube/config ]]; then
    echo "[+ master] no need to configuring regular user"
else
    echo "[+ master] configuring regular user"
    su vagrant
    mkdir -p /home/vagrant/.kube
    # Copy all the admin configurations into the newly created directory 
    sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    # Change the user from root to regular user that is non-root account
    sudo chown 1000:1000 /home/vagrant/.kube/config
fi

export KUBECONFIG=/etc/kubernetes/admin.conf
echo "[+ master] kube flannel"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
echo "[+ master] done"
