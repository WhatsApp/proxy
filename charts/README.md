<!-- Copyright (c) Meta Platforms, Inc. and affiliates.

License found in the LICENSE file in the root directory
of this source tree. -->
# WhatsApp Proxy Helm Charts

This guide outlines how to utilize the [Helm chart](https://helm.sh/) for whatsapp-proxy in order to run the proxy in a [kubernetes](https://kubernetes.io/) cluster.

**NOTE**: This is quite an advanced topic and requires general knowledge around kubernetes and deployments of containers in distributed infrastructure. A healthy knowledge of kubernetes is required to deploy this.

[<img alt="github" src="https://img.shields.io/badge/github-WhatsApp/proxy-8da0cb?style=for-the-badge&labelColor=555555&logo=github" height="20">](https://github.com/WhatsApp/proxy)
[<img alt="build status" src="https://img.shields.io/github/workflow/status/WhatsApp/proxy/ci/main?style=for-the-badge" height="20">](https://github.com/WhatsApp/proxy/actions?query=branch%3Amain)

## Before you begin

### Setup a Kubernetes Cluster

The quickest way to setup a Kubernetes cluster is with [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/), [AWS Elastic Kubernetes Service](https://aws.amazon.com/eks/) or [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/) using their respective quick-start guides.

For setting up Kubernetes on other cloud platforms or bare-metal servers refer to the Kubernetes [getting started guide](http://kubernetes.io/docs/getting-started-guides/).

### Install Helm

Get the latest [Helm release](https://github.com/helm/helm#install).

### Add Helm chart repo

Once you have Helm installed, add the repo as follows:

**TBD**

<!-- ```console
helm repo add whatsapp_proxy https://WhatsApp.github.io/proxy
helm repo update
``` -->

WhatsApp Proxy Helm charts can be also found on [ArtifactHub](https://artifacthub.io/packages/search?repo=WhatsApp).

## Search and install charts

```console
helm search repo WhatsApp/
helm install my-release WhatsApp/<chart>
```

**_NOTE_**: For instructions on how to install a chart follow instructions in its `README.md`.

## Contributing

We welcome all contributions. Please refer to [guidelines](../CONTRIBUTING.md) on how to make a contribution.
