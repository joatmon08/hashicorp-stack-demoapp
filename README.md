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
  - `infrastructure/` (takes 30+ minutes to provision!)
     - VPC (3 private subnets, 3 public subnets)
     - Boundary cluster (controllers, workers, and AWS RDS PostgreSQL database)
     - AWS Elastic Kubernetes Service cluster
     - AWS RDS (PostgreSQL) database for demo application
     - HashiCorp Virtual Network (peered to VPC)
     - HCP Consul
     - HCP Vault
   - `boundary-configuration`: Configures boundary with two organizations
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

## Deploy Kubernetes, Boundary, and HCP Clusters

1. Create a Terraform workspace named `infrastructure`
   1. Use the working directory `infrastructure`.
   1. Connect it to VCS Settings.
   1. Variables should include:
      ```plaintext
      private_ssh_key (sensitive): base64 encoded SSH Key for Boundary SSH
      database_password (sensitive): password for Amazon RDS PostgreSQL database for application
      ```
   1. Environment Variables should include:
      ```plaintext
      HCP_CLIENT_ID: HCP service principal ID
      HCP_CLIENT_SECRET (sensitive): HCP service principal secret
      AWS_ACCESS_KEY_ID: AWS access key ID
      AWS_SECRET_ACCESS_KEY (sensitive): AWS secret access key
      AWS_SESSION_TOKEN (sensitive): If applicable, the token for session
      ```

1. Queue to plan and apply. This creates VPCs and networks, an EKS cluster
   with three nodes in a private subnet, an Amazon RDS instance using PostgreSQL,
   a Boundary cluster (load balancer, workers, controllers, and database),
   HCP network with peering to the VPC, and HCP Consul cluster.

> Note: To delete the infrastructure, you must run `terraform destroy` a few times because
  of AWS timing out. After you finish destroying, you need to run
  `make clean-infrastructure` to remove the AWS auth ConfigMap from state.


## Configure Boundary

1. Create a Terraform workspace named `boundary-configuration`
   1. Use the working directory `boundary-configuration`.
   1. Connect it to VCS Settings.
   1. Variables should include:
      ```plaintext
      tfc_organization: your Terraform Cloud organization name
      tfc_workspace: infrastructure
      ```
      The configuration retrieves a set of variables using `terraform_remote_state`
      data source.
   1. Environment Variables should include:
      ```plaintext
      AWS_ACCESS_KEY_ID: AWS access key ID
      AWS_SECRET_ACCESS_KEY (sensitive): AWS secret access key
      AWS_SESSION_TOKEN (sensitive): If applicable, the token for session
      ```

1. Queue to plan and apply. This creates an organization with two scopes:
   - `core_infra`, which allows you to SSH into EKS nodes
   - `product_infra`, which allows you to access the PostgreSQL database

1. Only `product` users will be able to access `product_infra`.
   `operations` users will be able to access both `core_infra`
   and `product_infra`.

1. Set the `BOUNDARY_ADDR` environment variable to the Boundary endpoint.
   ```shell
   export BOUNDARY_ADDR=$(cd boundary-configuration && terraform output -raw boundary_endpoint)
   ```

1. As an example, you can use the following commands to log in
   first as an operations user and then as a product user.
   ```shell
   make ssh-operations
   ```

## Add Coffee Data to Database

1. To add data, you need to log into the PostgreSQL database.

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

1. Create a Terraform workspace named `consul-deployment`
   1. Use the working directory `consul-deployment`.
   1. Connect it to VCS Settings.
   1. Variables should include:
      ```
      tfc_organization: your Terraform Cloud organization name
      tfc_workspace: infrastructure
      ```
      The configuration retrieves a set of variables using `terraform_remote_state`
      data source.
   1. Environment Variables should include:
      ```
      HCP_CLIENT_ID: HCP service principal ID
      HCP_CLIENT_SECRET (sensitive): HCP service principal secret
      AWS_ACCESS_KEY_ID: AWS access key ID
      AWS_SECRET_ACCESS_KEY (sensitive): AWS secret access key
      AWS_SESSION_TOKEN (sensitive): If applicable, the token for session
      ```

1. Queue to plan and apply. This deploys Consul clients and a terminating gateway
   via the Consul Helm chart to the EKS cluster to join the HCP Consul servers.
   It also registers the database as an external service to Consul.

1. Update the [terminating gateway](https://www.consul.io/docs/k8s/connect/terminating-gateways#update-terminating-gateway-acl-token-if-acls-are-enabled) with a
   write policy to the database.
   ```shell
   make kubeconfig
   export CONSUL_HTTP_ADDR=<public HCP Consul address>
   export CONSUL_HTTP_TOKEN=<HCP Consul token>
   make configure-consul
   ```

> Note: To delete, you will need to run `make clean-vault` and comment out the `kubernetes.tf` and `consul.tf` files.


## Configure Vault

1. Create a Terraform workspace named `vault-deployment`
   1. Use the working directory `vault-deployment`.
   1. Connect it to VCS Settings.
   1. Variables should include:
      ```
      tfc_organization: your Terraform Cloud organization name
      tfc_workspace: infrastructure
      vault_private_address: Private Address of HCP Vault instance
      ```
      The configuration retrieves a set of variables using `terraform_remote_state`
      data source.
   1. Environment Variables should include:
      ```
      VAULT_ADDR: Public Address of HCP Vault instance
      VAULT_TOKEN (sensitive): HCP Vault root token
      AWS_ACCESS_KEY_ID: AWS access key ID
      AWS_SECRET_ACCESS_KEY (sensitive): AWS secret access key
      AWS_SESSION_TOKEN (sensitive): If applicable, the token for session
      ```

1. This sets up Kubernetes authentication method and PostgreSQL database engine.

> Note: To delete, you will need to run `make clean-vault` and comment out the `kubernetes.tf` and `database.tf` files.


## Deploy Example Application

1. To deploy the example application, run `make configure-application`.

> Note: To delete, you will need to run `make clean-application`.

## Credits

- The module for Boundary is based on the [Boundary AWS Reference Architecture](https://github.com/hashicorp/boundary-reference-architecture/tree/main/deployment)
  with slight modifications.

- The demo application comes from the [HashiCorp Demo Application](https://github.com/hashicorp-demoapp).