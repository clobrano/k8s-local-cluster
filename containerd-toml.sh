#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

echo "[+] creating containerd toml with systemd cgroup driver"

mkdir -pv /etc/containerd

/usr/local/bin/containerd config default > /etc/containerd/config.toml

sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml

systemctl restart containerd


