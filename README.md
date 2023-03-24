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

![Architecture diagram with HashiCorp Cloud Platform Consul and Vault connecting to an AWS EKS cluster and Boundary](./assets/diagram.png)

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

   - `boundary`: Configures Boundary with two projects, one for operations
      and the other for development teams.

   - `vault/setup/`: Deploy a Vault cluster via Helm chart and set up Kubernetes auth method

   - `certs/`: Sets up offline root CA and signs intermediate CA in Vault for Consul-related
      certificates.

   - `vault/consul/`: Set up Consul-related secrets engines.

   - `consul/setup/`: Deploys a Consul cluster via Helm chart. For demonstration
      of Vault as a secrets backend, deploys Consul servers + clients.

   - `consul/config/`: Sets up external service to database.

   - `vault/app/`: Set up secrets engines for applications.
      Archived in favor of `consul/cts/`.

- Other

   - `consul/cts/`: Deploys CTS to Kubernetes for setting up Vault database secrets
      based on database service's address

   - `application/`: Deploys the HashiCorp Demo Application (AKA HashiCups) to
      Kubernetes

   - `database/`: Configures HashiCorp Demo Application database

## Prerequisites

### CLIs

Be sure to download the CLIs for the following.

- Terraform 1.4
- Consul 1.12 (on Kubernetes)
- Vault 1.10
- Boundary 0.8
- Kubernetes 1.22

### Platforms

- Terraform Cloud
   - [Create an account](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up).
   - [Download the Terraform CLI](https://developer.hashicorp.com/terraform/downloads).
   - [Log into Terraform Cloud from the CLI](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-login).
- AWS Account
   - [Create an AWS EC2 keypair.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)
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

Next, set up all backends locally to point to Terraform Cloud. This demo
needs access to output variables from specific workspaces in order to
configure some things locally.

```shell
make terraform-init
```

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

### Configure Boundary

Go to the `boundary` workspace in Terraform Cloud.

Optionally, update the `boundary/terraform.auto.tfvars` file with
a list of users and groups you'd like to add.

Commit it up to your fork.

Start a new plan and apply it. This creates an organization with two scopes:
- `core_infra`, which allows you to SSH into EKS nodes
- `product_infra`, which allows you to access the PostgreSQL database

Only `product` users will be able to access `product_infra`.
`operations` users will be able to access both `core_infra`
and `product_infra`.

### Configure Vault (Kubernetes Auth Method)

Go to the `vault/setup` workspace in Terraform Cloud.

Start a new plan and apply it.

Terraform will set up [Kubernetes authentication method](https://www.vaultproject.io/docs/auth/kubernetes)
and deploy the [Vault Helm chart](https://github.com/hashicorp/vault-helm) to the cluster.

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

Using kustomize, deploy the Gateway CRDs.
```shell
make configure-kubernetes
```

Go to the `consul/setup` workspace in Terraform Cloud.

Start a new plan and apply it. This deploys Consul clients and a terminating gateway
via the Consul Helm chart to the EKS cluster to join the HCP Consul servers.

The Helm chart will get stuck because of
[this issue](https://github.com/hashicorp/consul-k8s/issues/1246).
Patch the API gateway to resolve.

```shell
make configure-api-gateway
```

### Reconfigure Certificates with Consul Cluster ID

API Gateway requires a SPIFFE-compliant URI in the service mesh certificate.
To bypass [this issue](https://github.com/hashicorp/consul-api-gateway/issues/208),
you will need to reconfigure the root CA with a SPIFFE URI that contains
the correct Consul cluster ID.

```shell
make configure-certs-spiffe
```

This forces a root certificate rotation for Consul service mesh.

### Configure Consul External Services & API Gateway

Update the [terminating gateway](https://www.consul.io/docs/k8s/connect/terminating-gateways#update-terminating-gateway-acl-token-if-acls-are-enabled)
with a write policy to the database.

```shell
make configure-terminating-gateway
```

Go to the `consul/config` workspace in Terraform Cloud.

Start a new plan and apply it. This does a few things, including:
   - registers the database as an external service to Consul
   - deploys the Consul API Gateway
   - sets up the application intentions.

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

### Configure Vault for Applications to Access Database

You can use
[Consul-Terraform-Sync](https://learn.hashicorp.com/tutorials/consul/consul-terraform-sync-intro?in=consul/network-infrastructure-automation)
to read the database
address from Consul and automatically configure a database
secrets engine in Vault using a Terraform module.

To do this, deploy CTS to Kubernetes.

```shell
make configure-cts
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

To use Boundary, use your terminal in the top level of this repository.

1. Set the `BOUNDARY_ADDR` environment variable to the Boundary endpoint.
   ```shell
   source set_terminal.sh
   ```

1. Use the example command in top-level `Makefile` to
   SSH to the EKS nodes as the operations team.
   ```shell
   make ssh-operations
   ```

1. Go to the Boundary UI and examine the "Sessions". You should get an active session
   in the Boundary list because you accessed the EKS node over SSH.

## Clean Up

Delete applications.

```shell
make clean-application
```

Revoke Vault credentials for applications.

```shell
make clean-vault
```

Disable CTS task, remove resources, and delete CTS.

```shell
make clean-cts
```

Go into Terraform Cloud and destroy resources
for the `consul-config` workspace.

Remove additional Consul resources.

```shell
make clean-consul
```

Go into Terraform Cloud and destroy resources
for the `consul-setup` workspace.

Remove API Gateway manifests.

```shell
make clean-kubernetes
```

Go into Terraform Cloud and destroy resources
for the `vault-consul` workspace.

Remove certificates for Consul from Vault.

```shell
make clean-certs
```

Go into Terraform Cloud and destroy resources
for the `vault-setup` workspace.

Go into Terraform Cloud and destroy resources
for the `boundary` workspace.

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