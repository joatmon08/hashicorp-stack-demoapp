#!/bin/bash

set -e

export CONSUL_HTTP_ADDR=$(cd infrastructure && terraform output -raw hcp_consul_public_address)
export CONSUL_HTTP_TOKEN=$(cd infrastructure && terraform output -raw hcp_consul_token)
export CONSUL_HTTP_SSL_VERIFY=false

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -raw hcp_vault_namespace)

vault token create -policy=connect-ca-hcp -format=json > certs/vault_token.json

export PRIVATE_VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_private_address)
export PRIVATE_VAULT_TOKEN=$(cat certs/vault_token.json | jq -r '.auth.client_token')

cat <<EOF > certs/new_config.json
{"Provider": "vault", "Config": { "Address": "${PRIVATE_VAULT_ADDR}", "Token": "${PRIVATE_VAULT_TOKEN}","RootPKIPath": "connect_root", "IntermediatePKIPath": "connect_inter", "LeafCertTTL": "72h", "RotationPeriod": "2160h", "IntermediateCertTTL": "8760h", "PrivateKeyType": "rsa", "PrivateKeyBits": 2048, "Namespace": "${VAULT_NAMESPACE}" }, "ForceWithoutCrossSigning": false}
EOF

# Update Vault as CA
curl -k -H "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" --request PUT --data @certs/new_config.json ${CONSUL_HTTP_ADDR}/v1/connect/ca/configuration

consul connect ca set-config -config-file certs/new_config.json
consul connect ca get-config

curl -k -H "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" --request GET ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots