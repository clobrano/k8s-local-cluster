#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

set -x
sudo apt install -y virt-manager qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm
newgrp libvirt
