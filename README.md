# WhatsApp Chat Proxy

This project aims to provide an open-proxy implementation based on [HAProxy](https://www.haproxy.org/) which allows users to proxy their mobile apps through a central hub in the event they are unable to contact WhatsApp directly.

**Current Version**: 1.0

## Setup and Installation

This section outlines a basic setup and configuration for the proxy container which supports upwards of 27K connections concurrently.

### Dependencies

1. [Docker](https://docs.docker.com/engine/install/)
2. [optional] [Docker compose](https://docs.docker.com/compose/)
3. [optional] Enable docker on startup (host system dependent)

If your version of docker doesn't come pre-installed with Docker compose, you can install a one-off version with (for Linux)

```bash
# Download the pkg
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
# Enable execution of the script
sudo chmod +x /usr/bin/docker-compose
```

### Building

You can build the proxy host container with

```bash
docker build /path/to/git/repo/ -t whatsapp_proxy:1.0
```

which will compile the container and tag it as `whatsapp_proxy:1.0` for easy reference.

### Running

You can manually execute the docker container with the following docker command

```bash
docker run -it -p 80:80 -p 443:443 -p 5222:5222 -p 8080:8080 -p 8443:8443 -p 8222:8222 -p 8199:8199 whatsapp_proxy:1.0
```

however normally you don't want to manually run the container except for testing scenarios. Therefore we recommend utilizing Docker compose which
is a helpful automation tool to manage setting up the container and necessary port forwards, etc without user interaction.

#### Automate the container lifecycle with Docker Compose

Docker compose is a tool to run multi-container deployments, but also helps automate the command-line arguments necessary to run a single container. It is a YAML definition file which denotes all of the settings to startup and run the container as well as restart strategies in the event the container crashes or self-restarts.

We provide a sample [docker-compose.yml](./proxy/ops/docker-compose.yml) file for you which defines a standard deployment of the proxy container. Once docker compose is installed, you can test your specific configuration by running docker compose interactively with

```bash
docker compose -f /path/to/this/repo/docker-compose.yml up
```

which will allow you to see the output from the build + container hosting process to identify if everything is setup correctly. When you are ready to run the container as a service, do

```bash
docker compose -f /path/to/this/repo/docker-compose.yml up -d
```

Note the `-d` flag which means "daemonize" and run as a service. To stop the container you can similarly do

```bash
docker compose down
```

Once you have a docker compose setup, you can also automate the deployment for host reboots by utilizing a `systemd` service (if your hosting environment supports it). We provide a sample [`docker_boot.service`](./proxy/ops/docker_boot.service) service definition for you which you should customize to your own environment. To install and setup the `systemd` service you can do the following

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

**NOTE:** Make sure to update the path to your specific `docker-compose.yml` file in the service definition `docker_boot.service`!

## Kubernetes deployment

See [Helm chart README](./helm/README.md)

# Architecture Overview

The provided proxy container exposes multiple ports depending on scenarios you may with to utilize for proxying. The basic ports are

1. 80: Standard web traffic (HTTP)
2. 443: Standard web traffic, encrypted (HTTPS)
3. 5222: Jabber protocol traffic (WhatsApp default)

There are also ports configured which accept incoming [proxy headers](https://www.haproxy.com/blog/use-the-proxy-protocol-to-preserve-a-clients-ip-address/) (version 1 or 2)
on connections, such that if you have some kind of network load balancer or something you can preserve the client ip address should you wish.

1. 8080: Standard web traffic (HTTP) with PROXY protocol expected
2. 8443: Standard web traffic, encrypted (HTTPS) with PROXY protocol expected
3. 8222: Jabber protocol traffic (WhatsApp default) with PROXY protocol expected

Additionally the container exposes a stats port on `:8199` which can be connected to directly with `http://<host-ip>:8199` which you can monitor
HAProxy statistics.

## Certificate generation for SSL encrypted ports

Ports 443 and 8443 are protected by a self-signed encryption certificate generated at container build time. There are some custom options should you wish to tweak the settings of the generated certificates

* `SSL_DNS` comma seperate list of alternative hostnames, no default
* `SSL_IP` comma seperate list of alternative IPs, no default

They can be set with commands like

```bash
docker build . --build-arg SSL_DNS=test.example.com
```

# Contributors
------------

The authors of this code are

* Sean Lawlor ([@slawlor](https://github.com/slawlor)).

To learn more about contributing to this project, [see this document](https://github.com/whatsapp/proxy/blob/main/CONTRIBUTING.md).

# License
-------

This project is licensed under [MIT](https://github.com/novifinancial/akd/blob/main/LICENSE-MIT).
