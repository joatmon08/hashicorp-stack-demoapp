#!/bin/bash

set -e

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -raw hcp_vault_namespace)

export PGUSER=$(vault kv get -field=username payments-app/static/payments)
export PGPASSWORD=$(vault kv get -field=password payments-app/static/payments)

boundary connect postgres \
    -dbname=payments \
    -target-name payments-app-database-postgres \
    -target-scope-name=products_infra \
    -- -f application/payments-app/database/setup.sql