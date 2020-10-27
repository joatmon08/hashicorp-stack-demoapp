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
1. HCP Consul bootstrap token, set as `export CONSUL_HTTP_TOKEN=<bootstrap token>`
1. HCP Vault (already set up with HVN + Cluster)
   1. You will need the private URL set as `export VAULT_ADDR=<HCP Vault private address>`.
   1. You will need the namespace set as `export VAULT_NAMESPACE=admin`.
1. HCP Vault admin token, set as `export VAULT_TOKEN=<Vault token>`.
1. `jq` installed

## Usage

1. Run `make secrets-consul`. This extracts the gossip key and host to create variable files.
   It also copies the `${CONSUL_HTTP_TOKEN}` environment variable into `secrets/token`.

1. Add the Consul and Vault addresses to `terraform.tfvars`.
   ```hcl
   name                                     = "hcp-demo"
   peering_connection_has_been_added_to_hvn = false
   hcp_vault_private_addr                   = ${VAULT_ADDR}
   hcp_consul_host                          = ${CONSUL_HOST}
   ```

1. Run `terraform init` and `terraform apply`. It will stop with an error.

1. Set up the peering connection in HVN (do not accept, this configuration will do it for you).

1. Set `terraform apply -var peering_connection_has_been_added_to_hvn = true`. This executes the HVN/HCP module to
   accept the peering connection and add the security groups for HCP Consul.

1. Run `make configure-consul` to install the Consul Helm chart to your EKS cluster.

1. Run `make configure-vault` to install the Vault Helm chart to your EKS cluster.

1. Run `make configure-waypoint` to install the Waypoint server to your EKS cluster.

1. Run `make configure-boundary` to configure the Boundary deployment.

1. Run `waypoint init` to create the Waypoint project.

1. Run `waypoint up -app database` to create a PostgreSQL database.

1. Run `make configure-db-creds` to configure Vault database secrets engine.

1. Run `waypoint up -app products` to create the products API.

1. Add an intention to Consul that allows products to access database in the
   default namespace.

1. Run `waypoint up -app public` to create the public API endpoint.

1. Add an intention to Consul that allows public to access products in the
   default namespace.

1. Run `make configure-resolvers` to create the Consul splitters and resolvers.

1. Run `waypoint up -app frontend` to create the demo application frontend. Access
   the URL output by Waypoint.

1. Add an intention to Consul that allows frontend to access public in the
   default namespace.

## Credits

- The module for Boundary is based on the [Boundary AWS Reference Architecture](https://github.com/hashicorp/boundary-reference-architecture/tree/main/deployment)
  with slight modifications.

- The demo application comes from the [HashiCorp Demo Application](https://github.com/hashicorp-demoapp).