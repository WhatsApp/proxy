# Deployments

## Cloud-init deployment
To quickly deploy a proxy on a new server without additional linux knowledge, follow these steps:

1. Copy the contents of `cloud/cloud-init.yml` to your clipboard.
1. Create a new server instance with your desired cloud provider.
1. During the instance creation process, look for an option to specify "cloud-init" or "user data".
1. Paste the contents of `cloud/cloud-init.yml` into this field.
1. Finish creating the server instance.