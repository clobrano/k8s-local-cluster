#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

set -x
kubeadm join \
    ${MASTER_IP}:6443 \
    --token ${TOKEN} \
    --discovery-token-unsafe-skip-ca-verification

