#!/bin/bash

set -e

export CONSUL_HTTP_ADDR=$(cd consul/setup && terraform output -raw consul_address)
export CONSUL_HTTP_TOKEN=$(cd consul/setup && terraform output -raw consul_token)
export CONSUL_HTTP_SSL_VERIFY=false

TRUSTED_DOMAIN=$(curl -k -H "X-Consul-Token:${CONSUL_HTTP_TOKEN}" $CONSUL_HTTP_ADDR/v1/connect/ca/roots | jq -r '.TrustDomain')

cd certs/terraform
terraform init
terraform apply -var="signed_cert=true" -var="trusted_domain=${TRUSTED_DOMAIN}"