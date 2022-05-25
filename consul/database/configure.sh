#!/bin/bash

set -e

export CONSUL_HTTP_ADDR=https://$(kubectl get svc consul-ui --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export CONSUL_HTTP_TOKEN=$(vault kv get -field=token consul/static/bootstrap)
export CONSUL_HTTP_SSL_VERIFY=false

consul acl policy update -name "database-write-policy" -rules @consul/database/policy.hcl

consul acl role update -id \
    $(consul acl role list -format json |jq -r '.[] | select (.Name == "consul-terminating-gateway-acl-role") | .ID') \
    -policy-name database-write-policy

kubectl apply -f consul/database/kubernetes.yaml

cd consul/database/terraform && terraform apply