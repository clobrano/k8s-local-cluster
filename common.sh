#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -e

echo [+ common] install dependencies
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    gnupg2 \
    curl

echo [+ common] install docker
if command -v docker >/dev/null; then
    echo [+ common] docker already installed
else
    # install using the "convenience script"
    curl -fsSL https://get.docker.com -o get-docker.sh
    chmod u+x ./get-docker.sh
    ./get-docker.sh
    sudo systemctl enable docker
    sudo usermod -G docker -a $USER
    newgrp docker
    sudo systemctl restart docker
fi
docker version

if command -v kubeadm >/dev/null; then
    echo [+ common] kubernetes already installed
else
    echo [+ common] install kubeadm without package manager
    echo [+ common] Install CNI plugins
    CNI_VERSION="v0.8.2"
    ARCH="amd64"
    sudo mkdir -p /opt/cni/bin
    curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

    echo [+ common] Install crictl
    DOWNLOAD_DIR=/usr/local/bin
    sudo mkdir -p $DOWNLOAD_DIR
    CRICTL_VERSION="v1.22.0"
    ARCH="amd64"
    curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

    echo [+ common] install kubeadm, kubelet, kubectl and add kubelet systemd service
    RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
    ARCH="amd64"
    cd $DOWNLOAD_DIR
    sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}
    sudo chmod +x {kubeadm,kubelet,kubectl}

    RELEASE_VERSION="v0.4.0"
    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
    sudo mkdir -p /etc/systemd/system/kubelet.service.d
    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

    systemctl enable --now kubelet
fi
kubeadm version
kubelet --version
kubectl version

echo [+ common] disable swap
sudo swapoff -a  
