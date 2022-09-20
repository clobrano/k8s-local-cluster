#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

# Installing kubeadm, kubelet, kubectl
CNI_VERSION="v0.8.2"
CRICTL_VERSION="v1.22.0"
K8S_VERSION="v0.4.0"
DOWNLOAD_DIR=/usr/bin

if command -v kubeadm >/dev/null; then
    echo [+] kubernetes already installed
else
    echo [+] install kubeadm without package manager

    echo [+] Install CNI plugins
    ARCH="amd64"
    sudo mkdir -p /opt/cni/bin
    curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz


    echo [+] Install crictl
    sudo mkdir -p $DOWNLOAD_DIR
    ARCH="amd64"
    curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz


    echo [+] install kubeadm, kubelet, kubectl and add kubelet systemd service
    RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
    ARCH="amd64"

    pushd $DOWNLOAD_DIR

    sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}
    sudo chmod +x {kubeadm,kubelet,kubectl}

    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service

    sudo mkdir -p /etc/systemd/system/kubelet.service.d

    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

    popd
fi

echo [+] start kubelet
systemctl enable --now kubelet
systemctl start kubelet


