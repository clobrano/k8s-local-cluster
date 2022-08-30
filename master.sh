#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

FLANNEL_CIDR="10.244.0.0/16"

echo "[+ master] kubeadm init (CIDR:$FLANNEL_CIDR, API SERVER ADV ADDR:$MASTER_IP)"
kubeadm config images pull
kubeadm init \
    --token ${TOKEN} \
    --pod-network-cidr=$FLANNEL_CIDR \
    --apiserver-advertise-address=$MASTER_IP \
    --ignore-preflight-errors=all \
    --v=6

echo "[+ master] configuring regular user"
if [[ ! -f $HOME/.kube/config ]]; then
    mkdir -p $HOME/.kube
    # Copy all the admin configurations into the newly created directory 
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    # Change the user from root to regular user that is non-root account
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
fi

export KUBECONFIG=/etc/kubernetes/admin.conf
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "[+ master] done"
