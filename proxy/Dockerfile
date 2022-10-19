# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# License found in the LICENSE file in the root directory
# of this source tree.
FROM haproxy:2.6.6-alpine

# Install dependencies for healthcheck support
USER root
RUN apk --update --no-cache add curl openssl jq bash

# Customization variables for certificate generation
ARG SSL_IP
ARG SSL_DNS

# Generate + copy the self-signed certificate settings
WORKDIR /certs
COPY src/generate-certs.sh /usr/local/bin/generate-certs.sh
RUN chmod +x /usr/local/bin/generate-certs.sh && \
    /usr/local/bin/generate-certs.sh && \
    mkdir --parents /etc/haproxy/ssl/ && \
    mv /certs/proxy.whatsapp.net.pem /etc/haproxy/ssl/proxy.whatsapp.net.pem && \
    chown haproxy:haproxy /etc/haproxy/ssl/proxy.whatsapp.net.pem
WORKDIR /

# Copy the public-ip setting + sshd startup script
COPY --chown=haproxy:haproxy src/set_public_ip_and_start.sh /usr/local/bin/set_public_ip_and_start.sh
RUN chmod +x /usr/local/bin/set_public_ip_and_start.sh

# Copy the HAProxy configuration
COPY --chown=haproxy:haproxy src/proxy_config.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN chown haproxy:haproxy /usr/local/etc/haproxy

# Copy + define the healthcheck
COPY src/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh
HEALTHCHECK --interval=10s --start-period=5s CMD bash /usr/local/bin/healthcheck.sh

# Validate the HAProxy configuration file (sanity check)
RUN haproxy -c -V -f /usr/local/etc/haproxy/haproxy.cfg

# Revert to the haproxy user for runtime operation
USER haproxy
# This is the startup command which also runs a background job to manage the WAPOX IPs
CMD /usr/local/bin/set_public_ip_and_start.sh
