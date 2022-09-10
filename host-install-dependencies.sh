#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

set -x

# Install upstream vagrant (https://www.vagrantup.com/downloads)
## Debian/Ubuntu
if command -v apt 2>/dev/null; then
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y vagrant virt-manager qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils 
fi

## Fedora
if command -v dnf 2>/dev/null; then
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf -y install vagrant 

    sudo dnf -y install libvirt virt-install libvirt-devel libxml2-devel make ruby-devel libguestfs-tools
fi

## Centos/RedHat (untested yet)
if command -v dnf 2>/dev/null; then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install vagrant
fi

# Add user to libvirt group
sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm
newgrp libvirt

vagrant plugin install vagrant-libvirt
