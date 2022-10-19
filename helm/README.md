# WhatsApp Proxy Kubernetes deployment

This guide outlines how to setup the [Helm chart](https://helm.sh/) for whatsapp-proxy in order to run the proxy in a [kubernetes](https://kubernetes.io/) cluster.

**NOTE**: This is quite an advanced topic and requires general knowledge around kubernetes and deployments of containers in distributed infrastructure. A healthy knowledge of kubernetes is required to deploy this.

## Dependencies

1. [Kubernetes](https://kubernetes.io/docs/setup/)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/) (configured to point to kubernetes cluster)
3. [Helm charts](https://helm.sh/docs/intro/install/)
