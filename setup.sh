#!/bin/bash

echo "Create defined dir"
mkdir -p /etc/defined

echo "Download dnclient"
curl -L https://dl.defined.net/$VERSION/linux/amd64/dnclient -o /etc/defined/dnclient
chmod +x /etc/defined/dnclient

echo "Install config"
echo $CONFIG | base64 -d > /etc/defined/config.yml

echo "Install service file"
cp defined.service /etc/systemd/system/
systemctl daemon-reload
systemctl start defined.service

sleep 3

echo "Show some systemd info"
systemctl status defined | head -n 8

echo "Show interface information"
ip addr | grep -A3 nebula99
