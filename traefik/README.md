# WhatsApp Chat Proxy (traefik version)

[<img alt="github" src="https://img.shields.io/badge/github-WhatsApp/proxy-8da0cb?style=for-the-badge&labelColor=555555&logo=github" height="20">](https://github.com/WhatsApp/proxy)
[![CI](https://github.com/WhatsApp/proxy/actions/workflows/ci.yml/badge.svg)](https://github.com/WhatsApp/proxy/actions/workflows/ci.yml)

If you are unable to connect directly to WhatsApp, a proxy can be used as a gateway between you and our servers. To help yourself or others re-establish connection to WhatsApp, you can set up a proxy server.

If you already have a proxy to use, you can connect it to WhatsApp by following the steps in this [article](https://faq.whatsapp.com/520504143274092).

## Frequently asked questions

**PLEASE READ THIS BEFORE OPENING AN ISSUE** We have an FAQ, which you can find here: [FAQ.md](https://github.com/whatsapp/proxy/blob/main/FAQ.md)

## What you'll need

1. [Docker](https://docs.docker.com/engine/install/) (enable Docker on startup if your host system allows)
2. [Docker compose](https://docs.docker.com/compose/)

## Setting up your proxy

### 1. Clone the repository to your local machine

```bash
git clone https://github.com/WhatsApp/proxy.git
```

You should see a folder called `proxy` created in the current directory.


### 2. [Install Docker](https://docs.docker.com/get-docker/) for your system

To confirm Docker is successfully installed:

```bash
docker --version
```

should display a line similar to `Docker version 20.10.21, build baeda1f`.

### 2. Install Docker compose

For Linux users, if your [version of Docker](https://docs.docker.com/desktop/install/linux-install/) doesn't come pre-installed with Docker compose, you can install Docker compose separately. The following command is for Debian and Ubuntu. Please refer to the [Docker documentation](https://docs.docker.com/compose/install/) for other installation options.

```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

## Running the proxy

### Check the configurations

The default configuration will be using traefik proxy with self-signed TLS certificates and [traefik.me](https://traefik.me/) as wildcard dns provider. This setup should work in most cases. However, if you are a power user or have specific preferences, for example:

- Use your own domain instead of default wildcard DNS
- Bring your own certificate files
- Use Let's Encrypt or other ACME providers
- Use alternative wildcard DNS providers
- Uirectly use IP addresses for connection (strongly **NOT** recommanded)

You can check the comments in configuration files and [Traefik Documentation](https://doc.traefik.io/traefik/) for more information.

### Set up Traefik proxy service

```
cd proxy/traefik
docker compose up -d && docker compose logs -f
```

If Traefik service is started successfully, it should display a line like `Configuration loaded from file: /etc/traefik/traefik.toml`

The service is automatically started on host boot, no more configuration is needed. If you want to stop and remove the service, run `docker compose down` inside the directory with *compose.yml* file.

The Traefik service does not exclusively occupy 80/443 and other ports on its own. It functions as a versatile reverse proxy with a wide range of features, similar to HAProxy and Nginx. For more advanced usage and how to Traefik as reverse proxy for other web services, please refer to [Traefik documentation](https://doc.traefik.io/traefik/).

## Configure your WhatsApp client

Assuming your proxy server is running on IP 192.168.1.1, then set your WhatsApp *Proxy host* to the following domain name.

```
whatsapp-192.168.1.1.traefik.me
```

Optionally, you can set the port numbers if default ports are blocked or you're under other network restrictions.

- Chat port
  - 443 (select "Use TLS"), default value.
  - 5222 (select "Use TLS")
  - 80
- Media port
  - 587, default value.
  - 7777

