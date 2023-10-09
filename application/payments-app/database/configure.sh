#!/bin/bash

set -e

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -raw hcp_vault_namespace)

boundary connect postgres \
    -dbname=payments \
    -target-name database-admin \
    -target-scope-name=payments-app \
    -- -f application/payments-app/database/setup.sql