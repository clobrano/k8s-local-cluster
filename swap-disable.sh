#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

echo [+] disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
