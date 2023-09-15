#!/bin/bash

export AWS_REGION=$(cd infrastructure && terraform output -raw region)
export BOUNDARY_ADDR=$(cd infrastructure && terraform output -raw hcp_boundary_endpoint)

mkdir -p secrets

echo "$(cd infrastructure && terraform output -raw hcp_boundary_password)" > secrets/admin

BOUNDARY_CLI_FORMAT=json boundary authenticate \
    password -login-name=$(cd infrastructure && terraform output -raw hcp_boundary_username) \
    -password file://secrets/admin -keyring-type=none | \
    jq -r '.item.attributes.token' > secrets/boundary-token

export BOUNDARY_TOKEN=$(cat secrets/boundary-token)
export TF_VAR_boundary_scope_id=$(cd boundary && terraform output -raw products_infra_scope_id)

cd database/

./terraform init
./terraform test