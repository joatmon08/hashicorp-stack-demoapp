#!/bin/bash

set -e

export CONSUL_HTTP_ADDR=$(cd consul/setup && terraform output -raw consul_address)
export CONSUL_HTTP_TOKEN=$(cd consul/setup && terraform output -raw consul_token)
export CONSUL_HTTP_SSL_VERIFY=false

export PRIVATE_VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_private_address)
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -raw hcp_vault_namespace)

## Update CA with new trusted domain for SPIFFE compliance

TRUSTED_DOMAIN=$(curl -k -H "X-Consul-Token:${CONSUL_HTTP_TOKEN}" $CONSUL_HTTP_ADDR/v1/connect/ca/roots | jq -r '.TrustDomain')

cd certs/terraform
terraform init
terraform apply -var="signed_cert=false" -var="trusted_domain=${TRUSTED_DOMAIN}"

cd ../..

## Sign intermediate CA for Consul servers
openssl x509 -req -in certs/server/intermediate/ca.csr \
    -extfile certs/extfile.cnf \
    -CA certs/server/root/ca.crt -CAkey certs/server/root/ca.key \
    -CAcreateserial -out certs/server/intermediate/ca.crt -days 1096 -sha256

## Sign intermediate CA for Consul Connect
openssl x509 -req -in certs/connect/intermediate/ca.csr \
    -extfile certs/extfile.cnf \
    -CA certs/connect/root/ca.crt -CAkey certs/connect/root/ca.key \
    -CAcreateserial -out certs/connect/intermediate/ca.crt -days 1096 -sha256

## Sign intermediate CA for Consul API Gateway
openssl x509 -req -in certs/gateway/intermediate/ca.csr \
    -extfile certs/extfile.cnf \
    -CA certs/gateway/root/ca.crt -CAkey certs/gateway/root/ca.key \
    -CAcreateserial -out certs/gateway/intermediate/ca.crt -days 1096 -sha256

cd certs/terraform
terraform init
terraform apply -var="signed_cert=true" -var="trusted_domain=${TRUSTED_DOMAIN}"

cd ../..

## Update CA Configuration

cat <<EOF > certs/new_config.json
{"Provider":"vault","Config":{"Address":"${PRIVATE_VAULT_ADDR}","IntermediateCertTTL":"8760h","IntermediatePKIPath":"consul/connect/pki_int","LeafCertTTL":"72h","RootCertTTL":"87600h","RootPKIPath":"consul/connect/pki","auth_method":{"mount_path":"kubernetes","params":{"role":"consul-server"},"type":"kubernetes"},"namespace":"${VAULT_NAMESPACE}"},"ForceWithoutCrossSigning":false}
EOF

# Update Vault as CA
curl -k -H "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" --request PUT --data @certs/new_config.json ${CONSUL_HTTP_ADDR}/v1/connect/ca/configuration

consul connect ca set-config -config-file certs/new_config.json
consul connect ca get-config

kubectl delete pod -l app=consul -l component=server
kubectl rollout status statefulset consul-server

curl -k -H "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" --request GET ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots

kubectl delete pod -l app=consul -l component=client
kubectl rollout status daemonset consul-client

kubectl delete pod -l app=consul -l component=api-gateway-controller
kubectl delete pod -l app=consul -l component=connect-injector
kubectl delete pod -l app=consul -l component=controller
kubectl delete pod -l app=consul -l component=terminating-gateway
kubectl delete pod -l app=consul -l component=webhook-cert-manager