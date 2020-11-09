# HashiCorp Demo Application with Boundary, Waypoint, & HashiCorp Cloud Platform

This is the HashiCorp demo application on Amazon EKS. It incorporates the following
tools:

* Terraform
* Waypoint
* HCP Consul
* HCP Vault
* Boundary

![Diagram of Infrastructure](./assets/diagram.png)

## Prerequisites

1. Terraform Cloud as Backend, state only (or reconfigure `terraform` directive in `providers.tf`)
1. AWS Account
1. HCP Consul (already set up with HVN + Cluster) - you will need the `client_config.json` and `ca.pem` copied to the `secrets` folder.
   1.  You will need the public URL set as `export CONSUL_HTTP_ADDR=<HCP Consul public URL>`.
   1.  You will need the bootstrap token set as `export CONSUL_HTTP_TOKEN=<bootstrap token>`.
1. HCP Vault (already set up with HVN + Cluster)
   1. You will need the private URL set as `export VAULT_ADDR=<HCP Vault public URL>`.
   1. You will need the namespace set as `export VAULT_NAMESPACE=admin`.
   1. HCP Vault admin token, set as `export VAULT_TOKEN=<Vault token>`.
1. `jq` installed

## Usage

1. Add the Consul and Vault addresses to `terraform.tfvars`.
   ```hcl
   name                                     = "hcp-demo"
   peering_connection_has_been_added_to_hvn = false
   hcp_vault_private_addr                   = ${HCP_VAULT_PRIVATE_ADDRESS}
   hcp_consul_host                          = ${HCP_CONSUL_PRIVATE_ADDRESS}
   ```

1. Run `make setup` and enter `yes` to create the EKS cluster, VPC, and Boundary.

1. Set up the peering connection in HVN (do not accept, this configuration will do it for you).

1. In `terraform.tfvars`, set `peering_connection_has_been_added_to_hvn` to true. This executes the HVN/HCP
   module to accept the peering connection and add the security groups for HCP Consul.
   ```hcl
   name                                     = "hcp-demo"
   peering_connection_has_been_added_to_hvn = true
   hcp_vault_private_addr                   = ${HCP_VAULT_PRIVATE_ADDRESS}
   hcp_consul_host                          = ${HCP_CONSUL_PRIVATE_ADDRESS}
   ```

1. Run `make setup` and enter `yes` to configure the HVN peering connection.

1. Run `make configure-consul` to install the Consul Helm chart to your EKS cluster.

1. Run `make configure-vault` to install the Vault Helm chart to your EKS cluster.

1. Run `make configure-waypoint` to install the Waypoint server to your EKS cluster.

1. Run `make configure-boundary` to configure the Boundary deployment.

1. Run `make configure-consul-intentions` to set up Consul intentions and allow traffic
   between services.

1. Run `waypoint init` to create the Waypoint project.

1. Run `waypoint up -app database` to create a PostgreSQL database.

1. Run `make configure-db-creds` to configure Vault database secrets engine.

1. Run `waypoint up -app products` to create the products API.

1. Run `waypoint up -app public` to create the public API endpoint.

1. Run `waypoint up -app frontend` to create the demo application frontend. Access
   the URL output by Waypoint.

## Credits

- The module for Boundary is based on the [Boundary AWS Reference Architecture](https://github.com/hashicorp/boundary-reference-architecture/tree/main/deployment)
  with slight modifications.

- The demo application comes from the [HashiCorp Demo Application](https://github.com/hashicorp-demoapp).