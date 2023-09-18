# HashiCorp Demo Application with Boundary, Consul, & Vault on Kubernetes

This is a demo of using Boundary, Consul, and Vault to secure
an application on Kubernetes.

Boundary controls user access to databases and test endpoints.
Consul secures service-to-service communication.
Vault secures the Consul cluster and issues temporary credentials
for an application to access a database

* [Navigation](#navigation)
* [Prerequisites](#prerequisites)
* [Setup](#setup)
* [Explore](#explore)
* [Clean Up](#clean-up)
* [Credits](#credits)
* [Additional References](#additional-references)

## Navigation

Each folder contains a few different configurations.

- Terraform Configurations

  - `infrastructure/`: All the infrastructure to run the system.
     - VPC (3 private subnets, 3 public subnets)
     - Boundary cluster (controllers, workers, and AWS RDS PostgreSQL database)
     - AWS Elastic Kubernetes Service cluster
     - AWS RDS (PostgreSQL) database for demo application
     - HashiCorp Virtual Network (peered to VPC)
     - HCP Consul
     - HCP Vault

   - `vault/setup/`: Deploy a Vault cluster via Helm chart and set up Kubernetes auth method

   - `boundary`: Configures Boundary with two projects, one for operations
      and the other for development teams.

   - `argocd/setup/`: Deploys an ArgoCD cluster to configure applications

   - `argocd/config/`: Deploys an ArgoCD proejcts

   - `certs/`: Sets up offline root CA and signs intermediate CA in Vault for Consul-related
      certificates.

   - `vault/consul/`: Set up Consul-related secrets engines.

   - `consul/setup/`: Deploys a Consul cluster via Helm chart. For demonstration
      of Vault as a secrets backend, deploys Consul servers + clients.

   - `vault/app/`: Set up secrets engines for applications.
      Archived in favor of `consul/cts/`.

- Other

   - `consul/config/`: Updates Consul ACL policies for terminating gateways and sets up Argo CD
     project for Consul configuration

   - `argocd/applications/`: Describes Argo CD applications to deploy

   - `database/`: Configures HashiCorp Demo Application database

## Prerequisites

### CLIs

Be sure to download the CLIs for the following.

- Terraform 1.5
- Consul 1.13 (on Kubernetes)
- Vault 1.10
- Boundary 0.13
- Kubernetes 1.26

### Platforms

- Terraform Cloud
   - [Create an account](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up).
   - [Download the Terraform CLI](https://developer.hashicorp.com/terraform/downloads).
   - [Log into Terraform Cloud from the CLI](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-login).
- AWS Account
- HashiCorp Cloud Platform account
   - You need access to HCP Consul and Vault.
   - Create a [service principal](https://portal.cloud.hashicorp.com/access/service-principals)
      for the HCP Terraform provider.
- `jq` installed
- Fork this repository.

## Setup

### Bootstrap Terraform Cloud workspaces.

Start by setting up Terraform Cloud workspaces for all infrastructure. We divide the infrastructure provisioning
from the deployment of services into separate states. This enforces a unidirectional dependency.

Before you start, make sure you:
   - [Create a Terraform Cloud account](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up).
   - [Download the Terraform CLI](https://developer.hashicorp.com/terraform/downloads).
   - [Log into Terraform Cloud from the CLI](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-login).

Go to the `bootstrap` directory.

```shell
cd bootstrap
```

Copy `tfvars.example` to `terraform.auto.tfvars`.

```shell
cp tfvars.example terraform.auto.tfvars
```

Update `terraform.auto.tfvars` with the required variables
and credentials. **DO NOT COMMIT THIS FILE AS IT CONTAINS
CREDENTIALS.**

> Note: For the HashiCorp folks, use doormat to push credentials
> up to the Terraform Cloud workspaces individually and leave AWS credentials
> blank in `terraform.auto.tfvars`. The session
> tokens cannot be loaded into variable sets. Use the command
> `doormat aws --account $AWS_ACCOUNT_ID tf-push --organization hashicorp-stack-demoapp --workspace infrastructure,boundary,consul-config,consul-setup,vault-setup`.

```shell
vim terraform.auto.tfvars
```

Initialize Terraform.

```shell
terraform init
```

Run Terraform and enter "yes" to apply.

```shell
terraform apply
```

If you log into Terraform Cloud and navigate to the `hashicorp-stack-demoapp`
organization, all the workspaces will be set up.

> Note: If you are using a different organization name other than `hashicorp-stack-demoapp`,
> update all `backend.tf` files to use the correct TFC organization.

### Deploy infrastructure.

> Note: When you run this, you might get the error `Provider produced inconsistent final plan`.
> This is because we're using [`default_tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags).
> Re-run the plan and apply to resolve the error.

Go to the `infrastructure` workspace in Terraform Cloud.

Update the `infrastructure/terraform.auto.tfvars` file with
your chosen region.

Commit it up to your fork.

Start a new plan and apply it. It can take more than 15 minutes to provision!

### Configure Vault (Kubernetes Auth Method)

Go to the `vault/setup` workspace in Terraform Cloud.

Start a new plan and apply it.

Terraform will set up [Kubernetes authentication method](https://www.vaultproject.io/docs/auth/kubernetes)
and deploy the [Vault Helm chart](https://github.com/hashicorp/vault-helm) to the cluster.

It also sets up a key-value secrets engine to store the Boundary worker token.

### Configure Boundary

Go to the `boundary` workspace in Terraform Cloud.

Optionally, update the `boundary/terraform.auto.tfvars` file with
a list of users and groups you'd like to add.

Commit it up to your fork.

> __NOTE__: Terraform will error out the first time you run it, as it
> waits for the Boundary worker to start up and store its token into
> Vault. Re-run after waiting a few moments.

Start a new plan and apply it. This creates an organization with two scopes:
- `core_infra`, which allows you to SSH into EKS nodes
- `product_infra`, which allows you to access the PostgreSQL database

Only `product` users will be able to access `product_infra`.
`operations` users will be able to access both `core_infra`

### Configure Argo CD

Go to the `argocd-setup` workspace in Terraform Cloud.

Commit it up to your fork.

This deploys an Argo CD HA cluster. You can get the initial `admin` password
using the Argo CD CLI or from a Kubernetes secret.

### Configure Argo CD Projects

Go to the `argocd-config` workspace in Terraform Cloud.

Commit it up to your fork.

This deploys an Argo CD projects that separate applications.

### Configure Offline Root CA for Consul

As a best practice, store root CAs away from Vault. To demonstrate this, we generate
a root CA offline. We use three separate root CAs:

- Cluster Root CA
  - Level 1 Intermediate CA (server root)
  - Level 2 Intermediate CA (server intermediate)

- Service Mesh Root CA for mTLS: This requires three levels because
  we will need to reconfigure the CA for the correct SPIFFE URI.
  - Level 1 Intermediate CA
  - Level 2 Intermediate CA (service mesh root)
  - Level 3 Intermediate CA (service mesh intermediate)

- API Gateway Root CA
  - Level 1 Intermediate CA (gateway root)
  - Level 2 Intermediate CA (gateway intermediate)

> __NOTE:__ This is a local Terraform command in order to secure the offline root CA.

Run the command to create a root CA as well as the intermediate CAs, and
store the intermediate CAs in Vault. Enter "yes" for Terraform to configure
Vault PKI secrets engine and add a passphrase as required.

```shell
make configure-certs
```

### Configure Vault for Consul (PKI Secrets Engine)

Go to the `vault/consul` workspace in Terraform Cloud.

Start a new plan and apply it.

Terraform will set up the PKI secrets engine for TLS in the Consul cluster
(not the service mesh).

### Configure Consul

Go to the `consul/setup` workspace in Terraform Cloud.

Start a new plan and apply it. This deploys Consul clients and a terminating gateway
via the Consul Helm chart to the EKS cluster to join the HCP Consul servers.

### Configure Consul API Gateway

Run `make configure-consul` to deploy resources to set up the Consul API Gateway.

### Configure Terraform Cloud Operator

Run `make configure-tfc` to deploy resources to set up the Consul API Gateway.

### Add Coffee Data to Database

To add data, you need to log into the PostgreSQL database. However, it's on a private
network. You need to use Boundary to proxy to the database.

1. Set up all the variables you need in your environment variables.
   ```shell
   source set_terminal.sh
   ```

1. Run the following commands to log in and load data into the `products`
   database.
   ```shell
   make configure-db
   ```

If you try to log in as a user of the `products` team, you can print
out the tables.
```shell
make postgres-products
```

### Deploy Example Application

To deploy the example application, run `make configure-application`.

You can check if everything by checking the pods in Kubernetes.

```shell
$ kubectl get pods

NAME                                                          READY   STATUS    RESTARTS   AGE
## omitted for clarity
frontend-5d7f97456b-2fznv                      2/2     Running   0          15m
nginx-59c9dbb9ff-j9xhc                         2/2     Running   0          15m
payments-67c89b9bc9-kbb9r                      2/2     Running   0          16m
product-55989bf685-ll5t7                       3/3     Running   0          5m5s
public-64ccfc4fc7-jd7v7                        2/2     Running   0          8m17s
```

Port forward the `nginx` service to [http://localhost:8080](http://localhost:8080).

```shell
kubectl port-forward svc/nginx 8080:80
```

You'll get a UI where you can order your coffee.

### Set up a route to the frontend through the API Gateway

To set up a route on the API gateway, deploy
an `HTTPRoute`.

```shell
make configure-route
```

## Explore

To log into any of the machines in this demo, you'll need the SSH key.

```shell
make get-ssh
```

This will save the private SSH key into `id_rsa.pem` at the top level
of this repository.

Set the `BOUNDARY_ADDR` environment variable to the Boundary endpoint.
```shell
source set_terminal.sh
```

Log into Boundary as the `operations` persona.
```shell
make boundary-operations-auth
```

Use the example command in top-level `Makefile` to
SSH to the EKS nodes as the operations team.
```shell
make ssh-k8s-nodes
```

Go to the Boundary UI and examine the "Sessions". You should get an active session
in the Boundary list because you accessed the EKS node over SSH.

## Clean Up

Remove applications.

```shell
make clean-application
```

Remove Terraform Cloud Operator.

```shell
make clean-tfc
```

Remove API Gateway configuration.

```shell
make clean-consul
```

Go into Terraform Cloud and destroy resources
for the `consul-setup` workspace.

Go into Terraform Cloud and destroy resources
for the `vault-consul` workspace.

Remove certificates for Consul from Vault.

```shell
make clean-certs
```

Go into Terraform Cloud and destroy resources
for the `argocd-config` workspace.

Go into Terraform Cloud and destroy resources
for the `argocd-setup` workspace.

Go into Terraform Cloud and destroy resources
for the `boundary` workspace.

Go into Terraform Cloud and destroy resources
for the `vault-setup` workspace.

Go into Terraform Cloud and destroy resources
for the `infrastructure` workspace.

## Credits

- The demo application comes from the [HashiCorp Demo Application](https://github.com/hashicorp-demoapp).

## Additional References

- portal.cloud.hashicorp.com/sign-up
- consul.io/docs/k8s/installation/vault
- vaultproject.io/docs/secrets/pki
- consul.io/docs/nia
- vaultproject.io/docs/auth/kubernetes
- consul.io/docs/security/acl/auth-methods/kubernetes
- hashi.co/k8s-vault-consul
- hashi.co/k8s-consul-api-gateway