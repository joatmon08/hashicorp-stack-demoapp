#!/bin/bash

set -e

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=admin

export CERT_C="US"
export CERT_ST="California"
export CERT_L="San Francisco"

## Generate offline root CA for Consul servers

mkdir -p certs/server/root
mkdir -p certs/server/intermediate

openssl genrsa -des3 -out certs/server/root/ca.key 4096
openssl req -new -x509 -days 3650 -key certs/server/root/ca.key \
    -out certs/server/root/ca.crt -config certs/openssl.cnf \
    -subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=HashiCorp/OU=HashiConf/CN=Consul Server Root CA"

## Generate offline root CA for Consul Connect

mkdir -p certs/connect/root
mkdir -p certs/connect/intermediate

openssl genrsa -des3 -out certs/connect/root/ca.key 4096
openssl req -new -x509 -days 3650 -key certs/connect/root/ca.key \
    -out certs/connect/root/ca.crt -config certs/openssl.cnf \
    -subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=HashiCorp/OU=HashiConf/CN=Consul Connect Root CA"

## Generate offline root CA for Consul API Gateway

mkdir -p certs/gateway/root
mkdir -p certs/gateway/intermediate

openssl genrsa -des3 -out certs/gateway/root/ca.key 4096
openssl req -new -x509 -days 3650 -key certs/gateway/root/ca.key \
    -out certs/gateway/root/ca.crt -config certs/openssl.cnf \
    -subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=HashiCorp/OU=HashiConf/CN=Consul API Gateway Root CA"

## Set up PKI secrets engine and set the intermediate

cd certs/terraform
terraform init
terraform apply -var="signed_cert=false"

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

## Load the signed intermediate certs into Vault

cd certs/terraform
terraform apply -var="signed_cert=true"

cd ../..