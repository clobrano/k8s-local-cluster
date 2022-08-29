#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

CONTAINERD_VER="1.6.8"
RUNC_VER="1.1.4"
CNI_PLUGIN_VER="1.1.1"
CNI_VERSION="v0.8.2"
CRICTL_VERSION="v1.22.0"
K8S_VERSION="v0.4.0"

set -e
echo [+ common] install dependencies
sudo apt-get update
sudo apt-get install -y \
    socat \
    conntrack \
    apt-transport-https \
    gnupg2 \
    curl

if [ ! -f /usr/lib/systemd/system/containerd.service ]; then
    echo "[+ containerd] installing containerd v${CONTAINERD_VER}"
    wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VER}/containerd-${CONTAINERD_VER}-linux-amd64.tar.gz


    tar Cxzvf /usr/local containerd-${CONTAINERD_VER}-linux-amd64.tar.gz
    rm containerd-${CONTAINERD_VER}-linux-amd64.tar.gz
    wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
    mv containerd.service /usr/lib/systemd/system/

    echo "[+ containerd] reload systemd daemon and service..."
    systemctl daemon-reload
    systemctl enable --now containerd
fi

if [[ ! -f /usr/local/sbin/runc ]]; then
    echo "[+ containerd] installing runc"
    wget https://github.com/opencontainers/runc/releases/download/v${RUNC_VER}/runc.amd64
    install -m 755 runc.amd64 /usr/local/sbin/runc
fi

if [[ ! -d /opt/cni/bin ]]; then
    echo "[+ containerd] cni-plugins v${CNI_PLUGIN_VER}"
    wget https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGIN_VER}/cni-plugins-linux-amd64-v${CNI_PLUGIN_VER}.tgz
    mkdir -p /opt/cni/bin
    tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${CNI_PLUGIN_VER}.tgz
fi


echo "[+ common] Forwarding IPv4 and letting iptables see bridged traffic"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
echo "[+ common] creating containerd toml with systemd cgroup driver"
mkdir -pv /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml

systemctl restart containerd

if command -v kubeadm >/dev/null; then
    echo [+ common] kubernetes already installed
else
    echo [+ common] install kubeadm without package manager
    echo [+ common] Install CNI plugins
    ARCH="amd64"
    sudo mkdir -p /opt/cni/bin
    curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

    echo [+ common] Install crictl
    DOWNLOAD_DIR=/usr/local/bin
    sudo mkdir -p $DOWNLOAD_DIR
    ARCH="amd64"
    curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

    echo [+ common] install kubeadm, kubelet, kubectl and add kubelet systemd service
    RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
    ARCH="amd64"
    cd $DOWNLOAD_DIR
    sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}
    sudo chmod +x {kubeadm,kubelet,kubectl}

    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
    sudo mkdir -p /etc/systemd/system/kubelet.service.d
    curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${K8S_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

fi
echo [+ common] start kubelet
systemctl enable --now kubelet
systemctl start kubelet

echo [+ common] disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
