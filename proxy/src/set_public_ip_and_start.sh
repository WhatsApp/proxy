#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# License found in the LICENSE file in the root directory
# of this source tree.

## About:
# This script replaces instances of #PUBLIC_IP in the HaProxy configuration files
# with the real public ip. There's an order of priority here which is
# 1. Environment variable
# 2. AWS EC2 Metadata endpoint
# 3. Third-party sources
# If all fails, we'll just not set the destination IP address

CONFIG_FILE="/usr/local/etc/haproxy/haproxy.cfg"

## Custom function to use as curl wrapper
# --silent: to reduce the nois eof response
# --show-error: to show errors in the response
# --fail: to fail on non-200 responses
# --ipv4: to force ipv4 resolution
# --max-time: to set a timeout
function fetch() {
  curl --silent --show-error --fail --ipv4 --max-time 2 "$@"
}

## PUBLIC_IP supplied from environment variable
if [[ $PUBLIC_IP == '' ]]
then
    echo "[PROXYHOST] No public IP address was supplied as an environment variable."
fi

## PUBLIC_IP retrieved from AWS EC2 metadata endpoint
if [[ $PUBLIC_IP == '' ]]
then
    # Attempt retrieval of the public ip from the meta-data instance
    PUBLIC_IP=$(fetch http://169.254.169.254/latest/meta-data/public-ipv4)
    if [[ $PUBLIC_IP == '' ]]
    then
        echo "[PROXYHOST] Failed to retrieve public ip address from AWS URI within 2s"
    fi
fi

## PUBLIC_IP retrieved from third-party sources
if [[ $PUBLIC_IP == '' ]]
then
    urls=(
        'https://icanhazip.com/'
        'https://ipinfo.io/ip'
        'https://domains.google.com/checkip'
    )

    # Attempt retrieval of the public ip from the third-party sources
    for url in "${urls[@]}"; do
        PUBLIC_IP="$(fetch "${url}")" && break
    done
    if [[ $PUBLIC_IP == '' ]]
    then
        echo "[PROXYHOST] Failed to retrieve public ip address from third-party sources within 2s"
    fi
fi

# Now if the public IP is available (test is for not-empty)
# then replace the instances in all haproxy config lines
if [[ -n "$PUBLIC_IP" ]]
then
    echo "[PROXYHOST] Public IP address ($PUBLIC_IP) in-place replacement occurring on $CONFIG_FILE"
    # Replace all instances of #PUBLIC_IP with the
    # haproxy configuration statement for the frontend which set's the destination
    # ip to the public ip of the container (which is necessary to determine our IP's
    # internally within WA)
    sed -i "s/#PUBLIC\_IP/tcp-request connection set-dst ipv4($PUBLIC_IP)/g" $CONFIG_FILE
fi

# Setup a new, on-the-fly certificate for the HTTPS port (so this re-generates each restart)
pushd /home/haproxy/certs
/usr/local/bin/generate-certs.sh
mv proxy.whatsapp.net.pem /etc/haproxy/ssl/proxy.whatsapp.net.pem
chown haproxy:haproxy /etc/haproxy/ssl/proxy.whatsapp.net.pem
popd

# Start HAProxy
haproxy -f "$CONFIG_FILE"

