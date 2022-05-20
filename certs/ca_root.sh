#!/bin/bash

set -e

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=admin

mkdir -p certs/root
mkdir -p certs/intermediate

openssl genrsa -des3 -out certs/root/ca.key 1024
openssl req -new -x509 -days 3650 -key certs/root/ca.key \
    -out certs/root/ca.crt -config certs/openssl.cnf

cd certs/terraform
terraform init
terraform apply -var="signed_cert=false"

cd ../..

openssl x509 -req -in certs/intermediate/ca.csr \
    -extfile certs/extfile.cnf \
    -CA certs/root/ca.crt -CAkey certs/root/ca.key \
    -CAcreateserial -out certs/intermediate/ca.crt -days 1096 -sha256

cd certs/terraform
terraform apply -var="signed_cert=true"

cd ../..