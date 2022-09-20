#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

RUNC_VER="1.1.4"
RUNC_BIN_LOC=/usr/local/sbin
if [[ -f ${RUNC_BIN_LOC}/runc ]]; then
    echo "[+] runc installed"
else
    echo "[+] installing runc"
    wget https://github.com/opencontainers/runc/releases/download/v${RUNC_VER}/runc.amd64
    install -m 755 runc.amd64 ${RUNC_BIN_LOC}/runc
fi


