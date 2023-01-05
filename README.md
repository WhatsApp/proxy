<!-- Copyright (c) Meta Platforms, Inc. and affiliates.

License found in the LICENSE file in the root directory
of this source tree. -->
# WhatsApp Chat Proxy

[<img alt="github" src="https://img.shields.io/badge/github-WhatsApp/proxy-8da0cb?style=for-the-badge&labelColor=555555&logo=github" height="20">](https://github.com/WhatsApp/proxy)
[<img alt="build status" src="https://img.shields.io/github/workflow/status/WhatsApp/proxy/ci/main?style=for-the-badge" height="20">](https://github.com/WhatsApp/proxy/actions?query=branch%3Amain)

If you are unable to connect directly to WhatsApp, a proxy can be used as a gateway between you and our servers. To help yourself or others re-establish connection to WhatsApp, you can set up a proxy server.

If you already have a proxy to use, you can connect it to WhatsApp by following the steps in this [article](https://faq.whatsapp.com/520504143274092).

## What you'll need

1. [Docker](https://docs.docker.com/engine/install/) (enable Docker on startup if your host system allows)
2. [Docker compose](https://docs.docker.com/compose/) (optional)

## Setting up your proxy

### 1. Clone the repository to your local machine
### 2. [Install Docker](https://docs.docker.com/get-docker/) for your system
### 3. Install Docker compose

For Linux users, if your [version of Docker](https://docs.docker.com/desktop/install/linux-install/) doesn't come pre-installed with Docker compose, you can install a one-off version (For Linux).

```bash
# Download the pkg
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
# Enable execution of the script
sudo chmod +x /usr/bin/docker-compose
```
### 3. Build the proxy host container

Build the proxy host container with

```bash
docker build /path_to_cloned_repository/proxy/ -t whatsapp_proxy:1.0
```

The container will be compiled and tagged as `whatsapp_proxy:1.0` for easy reference. 

**Please note**, the `/path_to_cloned_repository` should the same folder where you cloned this repository in step 1 above. Additionally, the Dockerfile to build the container is in a sub-folder **proxy** of the repository.

## Running the proxy

### Manually execute the container

You can manually execute the Docker container with the following `docker` command

```bash
docker run -it -p 80:80 -p 443:443 -p 5222:5222 -p 8080:8080 -p 8443:8443 -p 8222:8222 -p 8199:8199 whatsapp_proxy:1.0
```

### Automate the container lifecycle with Docker compose

Docker Compose is an automated tool to run multi-container deployments, but it also helps automate the command-line arguments necessary to run a single container. It is a YAML definition file that denotes all the settings to start up and run the container. It also has restart strategies in the event the container crashes or self-restarts. Docker Compose helps manage your container setup and necessary port forwards without user interaction. We recommend utilizing Docker Compose because you usually don’t want to manually run the container outside of testing scenarios.

We provide a sample [docker-compose.yml](./proxy/ops/docker-compose.yml) file for you which defines a standard deployment of the proxy container.

Once Docker compose is installed, you can test your specific configuration by running Docker compose interactively with:

```bash
docker compose -f /path/to/this/repo/docker-compose.yml up
```

This will allow you to see the output from the build + container hosting process and check that everything is set up correctly.

When you are ready to run the container as a service, do\*:

```bash
docker compose -f /path/to/this/repo/docker-compose.yml up -d
```

*\*Note the `-d` flag which means "daemonize" and run as a service.*

To stop the container you can similarly do:

```bash
docker compose down
```

### Automate host reboots with Docker compose

Once you have Docker compose set up, you can also automate the deployment for host reboots by utilizing a `systemd` service (if your hosting environment supports it).

We provide a sample [`docker_boot.service`](./proxy/ops/docker_boot.service) service definition for you which you should customize to your own environment.

To install and setup the `systemd` service\*:

```bash
# Copy the service definition to systemd folder
cp -v docker_boot.service /etc/systemd/system/
# Enable starting the service on startup
systemctl enable docker_boot.service
# Start the service (will docker compose up the container)
systemctl start docker_boot.service
# Check container status with
docker ps
```

*\*Make sure to update the path to your specific `docker-compose.yml` file in the service definition `docker_boot.service`*

## Kubernetes deployment

If you would like to configure your proxy using Kubernetes, or run the Docker runtime through Kubernetes, please see our [Helm chart README](./charts/README.md)

# An Overview of the WhatsApp Proxy Architecture

Depending on the scenario in which you utilize your proxy, the proxy container exposes multiple ports. The basic ports may include:

1. 80: Standard web traffic (HTTP)
2. 443: Standard web traffic, encrypted (HTTPS)
3. 5222: Jabber protocol traffic (WhatsApp default)

There are also ports configured which accept incoming [proxy headers](https://www.haproxy.com/blog/use-the-proxy-protocol-to-preserve-a-clients-ip-address/) (version 1 or 2)
on connections. If you have a network load balancer you can preserve the client IP address if you want.

1. 8080: Standard web traffic (HTTP) with PROXY protocol expected
2. 8443: Standard web traffic, encrypted (HTTPS) with PROXY protocol expected
3. 8222: Jabber protocol traffic (WhatsApp default) with PROXY protocol expected

Additionally the container exposes a statistics port on `:8199` which can be connected to directly with `http://<host-ip>:8199` which you can use to monitor
HAProxy statistics.

## Certificate generation for SSL encrypted ports

Ports 443 and 8443 are protected by a self-signed encryption certificate generated at container start time. There are some custom options should you wish to tweak the settings of the generated certificates

* `SSL_DNS` comma seperate list of alternative hostnames, no default
* `SSL_IP` comma seperate list of alternative IPs, no default

They can be set with commands like

```bash
docker build . --build-arg SSL_DNS=test.example.com
```

# Contributors
------------

The authors of this code are Sean Lawlor ([@slawlor](https://github.com/slawlor)).

To learn more about contributing to this project, [see this document](https://github.com/whatsapp/proxy/blob/main/CONTRIBUTING.md).

# License
-------

This project is licensed under [MIT](https://github.com/novifinancial/akd/blob/main/LICENSE-MIT).
