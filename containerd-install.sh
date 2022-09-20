#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

CONTAINERD_VER="1.6.8"
CNI_PLUGIN_VER="1.1.1"
CONTAINERD_SYSTEMD_LOC=/etc/systemd/system/

if [ -f ${CONTAINERD_SYSTEMD_LOC}/containerd.service ]; then
    echo "[+] installed already"
else
    echo "[+] installing containerd v${CONTAINERD_VER}"
    wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VER}/containerd-${CONTAINERD_VER}-linux-amd64.tar.gz

    tar Cxzvf /usr/local containerd-${CONTAINERD_VER}-linux-amd64.tar.gz
    rm containerd-${CONTAINERD_VER}-linux-amd64.tar.gz
    wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
    mv containerd.service ${CONTAINERD_SYSTEMD_LOC}/

    echo "[+ containerd] reload systemd daemon and service..."
    systemctl daemon-reload
    systemctl enable --now containerd
fi

if [[ -d /opt/cni/bin ]]; then
    echo "[+] cni-plugins installed"
else
    echo "[+] cni-plugins v${CNI_PLUGIN_VER}"
    wget https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGIN_VER}/cni-plugins-linux-amd64-v${CNI_PLUGIN_VER}.tgz
    mkdir -p /opt/cni/bin
    tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${CNI_PLUGIN_VER}.tgz
fi


