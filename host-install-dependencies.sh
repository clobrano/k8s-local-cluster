#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

set -x

# Install upstream vagrant (https://www.vagrantup.com/downloads)
if command -v apt>/dev/null; then
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y vagrant virt-manager qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils 
fi

# Add user to libvirt group
sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm
newgrp libvirt

vagrant plugin install vagrant-libvirt
