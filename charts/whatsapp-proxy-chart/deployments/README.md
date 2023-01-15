# Chart Deployment
This document explains how to create a Kuberentes cluster in one of the popular public cloud providers (e.g. AWS, GCP), and deploy the WhatsApp proxy Helm chart to your Kubernetes cluster.

## Prerequisites

### Helm

Install Helm using one of the methods outlined in this page: https://helm.sh/docs/intro/install/

## Create a Kubernetes cluster
To deploy your Helm chart, you will first need to create a Kubernetes cluster. You can create a simple Kubernetes cluster on a single server using one of the following tools:

* minikube (https://minikube.sigs.k8s.io/)
* microk8s (https://microk8s.io/)
* K3s (https://k3s.io/)
* kind (https://kind.sigs.k8s.io/)

These single-node Kubernetes clusters are relatively straightforward to set up, and are therefore not discussed here further. To see installation steps, please follow the links provided for each of the tools above.

The rest of the document will explain how to create a Kubernetes cluster on a managed Kubernetes service from one of the public cloud providers, such as:

* AWS: Amazon EKS (Elastic Kubernetes Service)
* GCP: GKE (Google Kubernetes Engine)

### Create a Kubernetes cluster on Amazon Elastic Kubernetes Service (EKS)
To create a Kubernetes cluster on Amazon EKS, you will need an AWS account: https://aws.amazon.com/

#### Install AWS CLI

Once you have created an AWS account, download the AWS CLI tool by following the steps for your operating system as outlined in this page: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions

Once the AWS CLI tool has been installed, you will need to configure it. You will first need an access key for your AWS user account. If you don't have an access key ID and secret access key pair to use, follow the steps below:

1. Go to https://console.aws.amazon.com/iamv2/home#/users.
2. In the list of users, click on your user name.
3. Go to the 'security credentials' tab.
4. Under 'Access keys', click 'Create access key'. If that button is grayed out and there are already two existing keys, then you already have two active access keys. Either use one of those keys, or delete one and create a new key.
5. In the dialog box that opens, make sure to download the CSV file that contains your access key ID and secret access key, as the secret access key is only displayed to you once.

Now, in a terminal window, type:

```
aws configure
```

Follow the steps to enter your access key ID and secret access key. Enter the region that you will be using (if you are unsure, you can use `us-east-1`). For output type, use `json`.

#### Install eksctl

Next, you will need to install the `eksctl` command-line tool. This tool will help you create a Kubernetes cluster.

> **Note**: You can also use the AWS Management Console to create a Kubernetes cluster. However, depending on the configuration parameters you select during cluster creation, you may have issues connecting to your cluster using the `kubectl` tool. This is due to the way EKS assigns the cluster creator identity when creating the cluster through the AWS Management Console, and requires that the identity accessing the cluster be the same as the cluster creator identity. By using the `eksctl` tool to create the cluster, you will not have issues accessing the cluster using `kubectl`. Therefore, in this document, we will be using `eksctl` to create the cluster.
> 
> For more information on this issue, see https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html#unauthorized

Install the `eksctl` tool for your operating system as outlined in this page: https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

#### Create your Kubernetes cluster

To create your Kubernetes cluster, run the following command:

```
eksctl create cluster --name <cluster_name> --region <region_code>
```

Replace `<cluster_name>` with a name of your choosing for your Kubernetes cluster, and `<region_code>` with the name of the region that you chose to use in AWS (e.g. `us-east-1`).

**Note**: This step will take about 15-20 minutes to complete. The logs will show the status of the cluster creation process.

**Note**: If you get an error like below:

```
Cannot create cluster 'sample-cluster' because us-east-1d, the targeted availability zone, does not currently have sufficient capacity to support the cluster. Retry and choose from these availability zones: us-east-1a, us-east-1b, us-east-1c
```

Rerun the above command, adding the `--zones` paramter with at least two availability zones from the list of suggested availability zones shown in the error. Your modified command should look similar to the following:

```
eksctl create cluster --name <cluster_name> --region <region_code> --zones us-east-1a,us-east-1b
```

#### Install kubectl

Next, you will need to install the `kubectl` tool. `kubectl` is your main point of interaction with your Kubenernetes cluster, once you create your cluster.

Follow the instructions for your operating system as outlined in this page: https://kubernetes.io/docs/tasks/tools/

> **Important**: The version of `kubectl` you install is important. The minor version of the installed `kubectl` cannot be more than 1 version different from your Kubernetes cluster version.
> 
> You can check the version of your Kubernetes cluster in EKS by going to https://console.aws.amazon.com/eks/. In the list, you can see the Kubernetes version for your cluster.
> 
> For example, if your cluster's Kubernetes version is 1.23, the `kubectl` version that you install cannot be lower than 1.22.x or higher than 1.24.x. You should always install the latest version of `kubectl` that is compatible with your Kubernetes cluster, so in this case, the latest `kubectl` version that you can install is 1.24.9.

#### Connect `kubectl` to your Kubernetes cluster

To access your Kubernetes from `kubectl`, run the following command:

```
aws eks --region <region_code> update-kubeconfig --name <cluster_name>
```

Replace `<region_code>` with the name of the AWS region you used, and `<cluster_name>` with the name of the cluster you created.

If this command was successful, you should now be able to access your Kubernetes cluster using `kubectl`. Run the following command:

```
kubectl get svc
```

You should get an output like the following:

```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   2d15h
```

#### Install the AWS Load Balancer Controller

To enable public access to the proxy service, Amazon EKS can deploy an AWS Network Load Balancer for the Kubernetes Service resource. To do so, you will need to install the AWS Load Balancer Controller. To learn more, see the home page for the AWS Load Balancer Controller project: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/

We will need to install the AWS Load Balancer Controller add-on, as outlined in this page: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

First, download the IAM policy file:

```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.6/docs/install/iam_policy.json
```

Next, create an IAM policy using the file that you downloaded, by running the following command:

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Then, create a service account role for the load balancer controller, by running the following command:

```
eksctl create iamserviceaccount \
  --cluster=<cluster_name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

In the above command, replace `<cluster_name>` with the name of your cluster and `111122223333` with your account ID.

Next, add the `eks-charts` repository to helm as follows:

```
helm repo add eks https://aws.github.io/eks-charts
```

Update your local helm repository index as follows:

```
helm repo update
```

Finally, run the following command to install the AWS Load Balancer Controller add-on:

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster_name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

Replace `<cluster_name>` with the name of your cluster.

> **Note**: If the AWS region you are using is not `us-west-2`, add this line to the command:
> 
> `--set image.repository=602401143452.dkr.ecr.region-code.amazonaws.com/amazon/aws-load-balancer-controller`
> 
> Replace `602401143452` with the registry code for your region (find the registry code from the list [here](https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html)), and replace `region-code` with the name of the AWS region you are using.
> 
> For example, if you are using region `us-east-1`, the command you run should look like the following:
> ```
> helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
>   -n kube-system \
>   --set clusterName=<cluster_name> \
>   --set serviceAccount.create=false \
>   --set serviceAccount.name=aws-load-balancer-controller \
>   --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller
> ```

If the previous command was successful, the running the following:

```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

You should see an output like the following:

```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           84s
```

Your Kubernetes cluster is now ready for deployments.

### Create a Kubernetes cluster on Google Kubernetes Engine (GKE)

To create a Kubernetes cluster on Google Kubernetes Engine, you will need a Google Cloud Platform account. Go to https://console.cloud.google.com/ to create an account.

#### Install `gcloud` CLI

First, start by installing the `gcloud` CLI tool. Follow the instructions for your operatint systems as outlined on this page: https://cloud.google.com/sdk/docs/install

Once `gcloud` has been installed, run the following command to authenticate the tool with your account:

```
gcloud auth login
```

Follow the steps in the browser window that opens to log in to your Google Cloud Platform account, and give permissions to the `gcloud` CLI tool to access your account.

#### Create a Kubernetes cluster on GKE

To create a Kubernetes cluter on GKE, we can use either the Google Cloud console, or the `gcloud` CLI tool. In this document, we will use the Google Cloud console.

1. Go to https://console.cloud.google.com/kubernetes.
    * If you see an 'Enable API' button, click it.
2. Once the GKE dashboard shows, click the 'Create' button at the top of the page.
3. GKE gives you two options for Kubernetes cluster creation and management: Standard and Autopilot. In this document, we will choose Standard. Click the 'Configure' button next to Standard.
4. In the next page, give your Kubernetes cluster a name.
5. Under 'Location type', if 'Zonal' is selected, note the selected zone name. If 'Regional' is selected, note the selected region name.
6. For the purposes of this document, you can leave the other options unchanged.
7. Click 'Create'.

It will take a few minutes for GKE to create the Kubernetes cluster.

Once the Kubernetes cluster has been created, continue to the next section.

#### Install kubectl

Next, you will need to install the `kubectl` tool. `kubectl` is your main point of interaction with your Kubenernetes cluster, once you create your cluster.

Follow the instructions for your operating system as outlined in this page: https://kubernetes.io/docs/tasks/tools/

> **Important**: The version of `kubectl` you install is important. The minor version of the installed `kubectl` cannot be more than 1 version different from your Kubernetes cluster version.
> 
> You can check the version of your Kubernetes cluster in GKE by going to https://console.cloud.google.com/kubernetes. In the list of clusters, click on the name of your cluster. In the cluster details page, under the 'Cluster basics' section, you can see the Kubernetes version for your cluster.
> 
> For example, if your cluster's Kubernetes version is 1.24.7-..., the `kubectl` version that you install cannot be lower than 1.23.x or higher than 1.25.x. You should always install the latest version of `kubectl` that is compatible with your Kubernetes cluster, so in this case, the latest `kubectl` version that you can install is 1.25.5.

#### Connect `kubectl` to your Kubernetes cluster

To access your Kubernetes from `kubectl`, first install an authentication plugin for the `gcloud` CLI tool by running the following command:

```
gcloud components install gke-gcloud-auth-plugin
```

Once the plugin has been installed, connect `kubectl` to your Kubernetes cluster by running one of the following commands:

* If your cluster's location type was zonal, run the following command:

  ```
  gcloud container clusters get-credentials <cluster_name> --zone <zone_name>
  ```

  Replace `<cluster_name>` with the name you used for your cluster, and `<zone_name>` with the name of the zone your cluster was created in.

* If your cluster's location type was regional, run the following command:

  ```
  gcloud container clusters get-credentials <cluster_name> --region <region_name>
  ```

  Replace `<cluster_name>` with the name you used for your cluster, and `<region_name>` with the name of the region your cluster was created in.

If the above command was successful, the running the following command:

```
kubectl get svc
```

should output something like the following:

```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.72.0.1    <none>        443/TCP   19h
```

You Kubernetes cluster is now ready for deployments.

## Deploying the Helm Chart to Your Kubernetes Cluster

After you have created your Kubernetes cluster and set up `kubectl` to access it, deploying the WhatsApp proxy Helm chart is very simple.

From the root of the chart directory (`whatsapp-proxy-chart/`), run one of the following commands:

* If you created your Kubernetes cluster on Amazon EKS, run the following command:
  ```
  helm install whatsapp-proxy . -f deployments/overrides/values.eks.yaml
  ```
* If you created your Kubernetes cluster on GKE, run the following command:
  ```
  helm install whatsapp-proxy . -f deployments/overrides/values.gke.yaml
  ```

The above command will install the Helm chart on your Kubernetes cluster.

To get the public endpoint for your deployment, run the following:

```
kubectl get svc
```

The output should look like the following:

```
NAME                                  TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                                                                                                 AGE
kubernetes                            ClusterIP      10.72.0.1     <none>        443/TCP                                                                                                 19h
whatsapp-proxy-whatsapp-proxy-chart   LoadBalancer   10.72.2.240   <PUBLIC_ENDPOINT>     8080:32220/TCP,8443:32287/TCP,8222:30054/TCP,5222:32734/TCP,80:31717/TCP,443:32498/TCP,8199:30617/TCP   3s
```

The public endpoint for your deployment will appear under EXTERNAL-IP.