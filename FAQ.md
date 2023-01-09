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