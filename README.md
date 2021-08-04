# HashiCorp Demo Application with Boundary, Consul, & Vault on Kubernetes

This is the HashiCorp demo application on Amazon EKS. It incorporates the following
tools:

- Terraform 1.0.3
- HashiCorp Cloud Platform (HCP) Consul 1.9.8
- HashiCorp Cloud Platform (HCP) Vault 1.7.3
- Boundary 0.4.0

![Diagram of Infrastructure](./assets/diagram.png)

Each folder contains a few different configurations.

- Terraform Modules
  - `boundary-deployment/`: This is a __local__ Terraform module because it includes
    the Boundary binary and an SSH key. It is referenced by `infrastructure/`.

- Terraform Configurations
  - `infrastructure/`: All the infrastructure to run the system.
     - VPC (3 private subnets, 3 public subnets)
     - Boundary cluster (controllers, workers, and AWS RDS PostgreSQL database)
     - AWS Elastic Kubernetes Service cluster
     - AWS RDS (PostgreSQL) database for demo application
     - HashiCorp Virtual Network (peered to VPC)
     - HCP Consul
     - HCP Vault
   - `boundary-configuration`: Configures Boundary with two projects, one for operations
      and the other for development teams.
   - `consul-deployment/`: Deploys a Consul cluster via Helm chart.
   - `vault-deployment/`: Deploy a Vault cluster via Helm chart.

- Kubernetes
   - `application/`: Deploys the HashiCorp Demo Application (AKA HashiCups)

## Prerequisites

1. Terraform Cloud
1. AWS Account
1. HashiCorp Cloud Platform account
   1. You need access to HCP Consul and Vault.
   1. Create a [service principal](https://portal.cloud.hashicorp.com/access/service-principals)
      for the HCP Terraform provider.
1. `jq` installed
1. Install HashiCorp Boundary and an SSH key to the `boundary-deployment/bin` directory.
   1. Download Boundary to `boundary-deployment/bin/boundary`.
      ```shell
      cd boundary-deployment/bin
      curl https://releases.hashicorp.com/boundary/0.4.0/boundary_0.4.0_linux_amd64.zip -o boundary.zip
      unzip boundary.zip
      rm boundary.zip
      ```
   1. Add an SSH key named `id_rsa` to `boundary-deployment/bin`. You can optionally add a passphrase.
      ```shell
      $ ssh-keygen -t rsa

      Enter file in which to save the key (~/.ssh/id_rsa): boundary-deployment/bin/id_rsa
      ```
1. Fork this repository.

## Deploy infrastructure.

> Note: When you run this, you might get the error `Provider produced inconsistent final plan`.
> This is because we're using [`default_tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags).
> Re-run the plan and apply to resolve the error.

First, set up the Terraform workspace.

1. Create a new Terraform workspace.
1. Choose "Version control workflow".
1. Connect to GitHub.
1. Choose your fork of this repository.
1. Name the workpsace `infrastructure`.
1. Select the "Advanced Options" dropdown.
1. Use the working directory `infrastructure`.
1. Select "Create workspace".

Next, configure the workspace's variables.

1. Variables should include:
   - `private_ssh_key` (sensitive): base64 encoded SSH Key for Boundary SSH
   - `database_password` (sensitive): password for Amazon RDS PostgreSQL database for application.
      __SAVE THIS PASSWORD! YOU'LL NEED IT TO LOG IN LATER!__
   - `client_cidr_block` (sensitive): public IP address of your machine, in `00.00.00.00/32` form.
      You get it by running `curl ifconfig.me` in your terminal.

1. Environment Variables should include:
   - `HCP_CLIENT_ID`: HCP service principal ID
   - `HCP_CLIENT_SECRET` (sensitive): HCP service principal secret
   - `AWS_ACCESS_KEY_ID`: AWS access key ID
   - `AWS_SECRET_ACCESS_KEY` (sensitive): AWS secret access key
   - `AWS_SESSION_TOKEN` (sensitive): If applicable, the token for session

If you have additional variables you want to customize, including __region__, make sure to update them in
the `infrastructure/terraform.auto.tfvars` file.

Finally, start a new plan and apply it. It can take more than 15 minutes to provision!

## Configure Boundary

First, set up the Terraform workspace.

1. Create a new Terraform workspace.
1. Choose "Version control workflow".
1. Connect to GitHub.
1. Choose your fork of this repository.
1. Name the workpsace `boundary-configuration`.
1. Select the "Advanced Options" dropdown.
1. Use the working directory `boundary-configuration`.
1. Select "Create workspace".

Next, configure the workspace's variables. This Terraform configuration
retrieves a set of variables using `terraform_remote_state` data source.

1. Variables should include:
   - `tfc_organization`: your Terraform Cloud organization name
   - `tfc_workspace`: `infrastructure`

1. Environment Variables should include:
   - `AWS_ACCESS_KEY_ID`: AWS access key ID
   - `AWS_SECRET_ACCESS_KEY` (sensitive): AWS secret access key
   - `AWS_SESSION_TOKEN` (sensitive): If applicable, the token for session


Queue to plan and apply. This creates an organization with two scopes:
- `core_infra`, which allows you to SSH into EKS nodes
- `product_infra`, which allows you to access the PostgreSQL database

Only `product` users will be able to access `product_infra`.
`operations` users will be able to access both `core_infra`
and `product_infra`.

To use Boundary, use your terminal in the top level of this repository.

1. Set the `BOUNDARY_ADDR` environment variable to the Boundary endpoint.
   ```shell
   export BOUNDARY_ADDR=$(cd boundary-configuration && terraform output -raw boundary_endpoint)
   ```

1. Use the example command in top-level `Makefile` to SSH to the EKS nodes as the operations team.
   ```shell
   make ssh-operations
   ```

## Add Coffee Data to Database

To add data, you need to log into the PostgreSQL database. However, it's on a private
network. You need to use Boundary to proxy to the database.

1. Set the `PGPASSWORD` environment variable to the database password you
   defined in the `infrastructure` Terraform workspace.
   ```shell
   export PGPASSWORD=<password that you set in infrastructure workspace>
   ```

1. Run the following commands to log in and load data into the `products`
   database.
   ```shell
   make configure-db
   ```

1. If you try to log in as a user of the `products` team, you can print
   out the tables.
   ```shell
   make postgres-products
   ```

1. Go to the Boundary UI and examine the "Sessions".
   ![List of active sessions in Boundary](./assets/boundary_sessions.png)


## Configure Consul

First, set up the Terraform workspace.

1. Create a new Terraform workspace.
1. Choose "Version control workflow".
1. Connect to GitHub.
1. Choose your fork of this repository.
1. Name the workpsace `consul-deployment`.
1. Select the "Advanced Options" dropdown.
1. Use the working directory `consul-deployment`.
1. Select "Create workspace".

Next, configure the workspace's variables. This Terraform configuration
retrieves a set of variables using `terraform_remote_state` data source.

1. Variables should include:
   - `tfc_organization`: your Terraform Cloud organization name
   - `tfc_workspace`: `infrastructure`

1. Environment Variables should include:
   - `HCP_CLIENT_ID`: HCP service principal ID
   - `HCP_CLIENT_SECRET` (sensitive): HCP service principal secret
   - `AWS_ACCESS_KEY_ID`: AWS access key ID
   - `AWS_SECRET_ACCESS_KEY` (sensitive): AWS secret access key
   - `AWS_SESSION_TOKEN` (sensitive): If applicable, the token for session

1. Queue to plan and apply. This deploys Consul clients and a terminating gateway
   via the Consul Helm chart to the EKS cluster to join the HCP Consul servers.
   It also registers the database as an external service to Consul.

1. Update the [terminating gateway](https://www.consul.io/docs/k8s/connect/terminating-gateways#update-terminating-gateway-acl-token-if-acls-are-enabled)
   with a write policy to the database. You need to run this outside of Terraform in your CLI!
   ```shell
   export CONSUL_HTTP_ADDR=$(cd infrastructure && terraform output -raw hcp_consul_public_address)
   export CONSUL_HTTP_TOKEN=$(cd consul-deployment && terraform output -raw hcp_consul_token)
   make configure-consul
   ```

> Note: To delete, you will need to run `make clean-consul` before destroying the infrastructure with Terraform.

## Configure Vault

First, set up the Terraform workspace.

1. Create a new Terraform workspace.
1. Choose "Version control workflow".
1. Connect to GitHub.
1. Choose your fork of this repository.
1. Name the workpsace `vault-deployment`.
1. Select the "Advanced Options" dropdown.
1. Use the working directory `vault-deployment`.
1. Select "Create workspace".

Next, configure the workspace's variables. This Terraform configuration
retrieves a set of variables using `terraform_remote_state` data source.

1. Variables should include:
   - `tfc_organization`: your Terraform Cloud organization name
   - `tfc_workspace`: `infrastructure`

1. Environment Variables should include:
   - `HCP_CLIENT_ID`: HCP service principal ID
   - `HCP_CLIENT_SECRET` (sensitive): HCP service principal secret
   - `AWS_ACCESS_KEY_ID`: AWS access key ID
   - `AWS_SECRET_ACCESS_KEY` (sensitive): AWS secret access key
   - `AWS_SESSION_TOKEN` (sensitive): If applicable, the token for session

Terraform will set up [Kubernetes authentication method](https://www.vaultproject.io/docs/auth/kubernetes)
and [PostgreSQL database secrets engine](https://www.vaultproject.io/docs/secrets/databases/postgresql).

> Note: To delete, you will need to run `make clean-vault` before destroying the infrastructure with Terraform.


## Deploy Example Application

1. To deploy the example application, run `make configure-application`.

> Note: To delete, you will need to run `make clean-application`.

## Credits

- The module for Boundary is based on the [Boundary AWS Reference Architecture](https://github.com/hashicorp/boundary-reference-architecture/tree/main/deployment)
  with slight modifications.

- The demo application comes from the [HashiCorp Demo Application](https://github.com/hashicorp-demoapp).