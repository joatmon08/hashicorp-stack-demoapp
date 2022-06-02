#!/bin/bash

set -e

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=admin

export CONSUL_HTTP_ADDR=$(cd consul/setup && terraform output -raw consul_address)
export CONSUL_HTTP_TOKEN=$(cd consul/setup && terraform output -raw consul_token)
export CONSUL_HTTP_SSL_VERIFY=false

consul acl policy create -name "database-write-policy" -rules @consul/config/policy.hcl

consul acl role update -id \
    $(consul acl role list -format json |jq -r '.[] | select (.Name == "consul-terminating-gateway-acl-role") | .ID') \
    -policy-name database-write-policy