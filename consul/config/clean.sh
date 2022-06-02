#!/bin/bash

set -e

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=admin

export CONSUL_HTTP_ADDR=https://$(kubectl get svc consul-ui --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export CONSUL_HTTP_TOKEN=$(vault kv get -field=token consul/static/bootstrap)
export CONSUL_HTTP_SSL_VERIFY=false

export TF_VAR_products_database=$(cd infrastructure && terraform output -raw product_database_address)

cd consul/database/terraform && terraform destroy -auto-approve

cd .. && kubectl delete -f kubernetes.yaml