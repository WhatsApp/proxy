# Frequently asked questions

## Getting started

First you need to clone the repository. You can do this with

```bash
git clone https://github.com/WhatsApp/proxy.git
```

## Common issues

### (1) The container won't build on Windows with `set_public_ip_and_start.sh: Not found`

This is likely a line encoding issue since the application is expecting unix-style line
encoding (EOL not CRLF). This resolved in PR [72](https://github.com/WhatsApp/proxy/pull/72)
and you should just need to pull the latest changes and try again.

### (2) I want to share my proxy to the community

This is great! We have created a dedicated GitHub issue to share these proxies. Access it here: [Issue #92](https://github.com/WhatsApp/proxy/issues/92)

### (3) My proxy isn't accessible publicly

Some common problems to investigate

1. Are the necessary ports open on your host?
2. If running in a cloud, are the necessary ports open on the cloud provider's firewall?
3. Can you access the statistics port (8199) locally? (at `http://127.0.0.1:8199`) If not, can you check the health of the container (if it's up and running) with `docker ps`?

### (4) What is the port configuration for this service + the client?

When only a host is specified in the app (ip or domain name), the client will attempt to connect to port 443 by default.

You can also re-map the ports exposed from the proxy to whatever you want. For example if you have a different service running on port 80, you can send the proxy container's port 80 to port 8081 for example. You can do this by changing the port mapping from `80:80` to `8081:80`. The format for these ports is `{HOST_MACHINE_PORT}:{CONTAINER_PORT}` so you're stating that
the container's port 80 binds to my machine's 8081, which is what will be exposed to the internet. An example of these port mapping can be found in the provided [docker-compose.yml](https://github.com/WhatsApp/proxy/blob/main/proxy/ops/docker-compose.yml#L14)

**NOTE** There is a caveat however to re-mapping port 443. Port 443 on the proxy runs a TLS encryption and the client knows to utilize TLS for connections to that port. All **OTHER** ports are expected to not have TLS. There is currently no way to configure this in the client so if you re-map the container's port 443 then it won't be able to connect. You can however safely remap ports 80 and 5222 freely and they should just work.

### (5) Does the proxy support HTTP(S) or SOCKS?

WhatsApp currently does **NOT** support anything besides TCP proxying. This is just copying the incoming bytes 
to WhatsApp on the other end. So we don't support running through any intermediary that is a HTTP proxy.

You are free to run your own pure TCP proxy as you see fit however, as long as it forwards to `g.whatsapp.net`. You aren't required to use this realization.

### (6) haproxy `cannot bind socket (Permission denied)`

See https://github.com/docker-library/haproxy/issues/160 for possible solutions.

### (7) Why do I need to expose 7 ports? 

The short answer is you don't. The primary ports WhatsApp uses can be 80, 443, or 5222. The other 3 connection ports are if you're hosting the 
proxy in an environment that will send the PROXY header (if you don't know what this is, you likely don't need to expose these ports). 

The last port is 8199 which is the "statistics" port of the underlying proxy process, HAProxy. We find this port is helpful for testing if your system is alive
and running properly or not. While the other ports 80 and 443 look like normal HTTP and HTTPS ports, your browser will not be able to connect to them as they
are just TCP forwarding the traffic to a server that is **NOT** HTTP based. For this reason, the statistics is a quick and easy way to check host health. 

That being said, if you're worried about detection, once running we recommend disabling all non-necessary ports. A **typical** host configuration would likely
just expose 80, 443, and 5222. You may re-map those however as you see fit, see point (4) above.

### (8) I'm seeing something like `executor failed running [/bin/sh -c apk --no-cache add curl openssl jq bash]: exit code: 4`

Please try re-building the container without the docker cache enabled.

```bash
docker build --no-cache proxy/ -t whatsapp-proxy:1.0
```

If you're still seeing a problem, you may fill out a bug report in the issues filling out all the requested information in the template.

### (9) Container is stuck after certificate generation

Actually thanks to recent community fixes, HAProxy is no longer printing 
any warning messages. Your host is actually running in interactive mode. You should be able to navigate to the host's port 8199 to view the statistics page ([http://localhost:8199](http://localhost:8199) on the machine running the proxy).

Related issue [#71](https://github.com/WhatsApp/proxy/issues/71)

### (10) Why isn't there a pre-built image on DockerHub?

Apologies in the delay, but it takes some time to organize access to the 
correct repositories. We're happy to announce there is now a pre-built image
based on the latest version in this repository. We'll strive to keep it
up-to-date as well. You can pull it (without needing to build locally) from

```bash
docker pull facebook/whatsapp_proxy:latest
```

After you've pulled the image, you can then run it with the same run commands as before except substituting in `facebook/whatsapp_proxy:latest` instead of `whatsapp_proxy:1.0`. This will point to the latest image for you without having to worry about building it yourself. Example run command might be

```bash
docker run -it -p 80:80 -p 443:443 -p 5222:5222 facebook/whatsapp_proxy:latest
```
