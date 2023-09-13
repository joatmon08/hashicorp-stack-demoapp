#!/bin/bash

set -e

export CONSUL_HTTP_ADDR=$(cd consul/setup && terraform output -raw consul_address)
export CONSUL_HTTP_TOKEN=$(cd consul/setup && terraform output -raw consul_token)
export CONSUL_HTTP_SSL_VERIFY=false

consul acl role update -id \
    $(consul acl role list -format json |jq -r '.[] | select (.Name == "consul-terminating-gateway-acl-role") | .ID') \
    -policy-name $(cd vault/consul && terraform output -raw consul_tgw_database_policy)

kubectl apply -f argocd/applications/consul