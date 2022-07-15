# defined-networking-connect

connect to a defined networking network in your actions workflow

## inputs

- defined-config: base64 encoded yaml config for your node; get this by configuring a test node first and copying the config
  - how-to: `echo $CONFIG | base64 -w0`
- dnclient-version: the version of the dnclient to use; needs the prefix found in the url

## usage

Add the following step in your GHA workflow:

```yaml
- id: set up network
  uses: rssnyder/defined-networking-connect@0.1.0
  with:
    defined-config: ${{ secrets.DEFINED_CONFIG }}
    dnclient-version: "cce733c1/v0.0.8"  # optional
```
[Unit]
Description=defined
Wants=basic.target
After=basic.target network.target
Before=sshd.service

[Service]
SyslogIdentifier=defined
StandardOutput=syslog
StandardError=syslog
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/etc/defined/dnclient run
Restart=always

[Install]
WantedBy=multi-user.target
[Unit]
Description=defined
Wants=basic.target
After=basic.target network.target
Before=sshd.service

[Service]
SyslogIdentifier=defined
StandardOutput=syslog
StandardError=syslog
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/etc/defined/dnclient run
Restart=always

[Install]
WantedBy=multi-user.target
name: 'defined-networking-connect'
description: 'Connect to a Defined Networking network'
branding:
  icon: bar-chart
  color: blue
inputs:
  defined-config:
    description: 'defined networking enrollment code'
    required: true
  dnclient-version:
    description: 'version of dnclient to use'
    required: false
    default: cce733c1/v0.0.8
runs:
  using: "composite"
  steps: 
    - shell: bash
      working-directory: ${{ github.action_path }}
      run: sudo ./setup.sh "${{ inputs.dnclient-version }}" "${{ inputs.defined-config }}"
#!/bin/bash

# usage: ./setup.sh <version> <base64 config>

echo "Create defined dir"
mkdir -p /etc/defined

echo "Download dnclient"
curl -L https://dl.defined.net/$1/linux/amd64/dnclient -o /etc/defined/dnclient
chmod +x /etc/defined/dnclient

echo "Install config"
echo $2 | base64 -d > /etc/defined/config.yml

echo "Install service file"
cp defined.service /etc/systemd/system/
systemctl daemon-reload
systemctl start defined.service

sleep 3

echo "Show some systemd info"
systemctl status defined | head -n 8

echo "Show interface information"
ip addr | grep -A3 nebula99
