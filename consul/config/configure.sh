#!/bin/bash

set -e

export CONSUL_HTTP_ADDR=$(cd infrastructure && terraform output -raw hcp_consul_public_address)
export CONSUL_HTTP_TOKEN=$(cd infrastructure && terraform output -raw hcp_consul_token)

consul acl role update -id \
    $(consul acl role list -format json |jq -r '.[] | select (.Name == "consul-terminating-gateway-acl-role") | .ID') \
    -policy-name $(cd vault/applications && terraform output -raw consul_tgw_database_policy)

kubectl apply -f argocd/applications/consul/