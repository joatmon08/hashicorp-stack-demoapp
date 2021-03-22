#!/bin/bash

consul acl policy create -name "database-write-policy" -rules @consul-deployment/terminating-gateway/write-policy.hcl

accessor_id=$(consul acl token list -format json | \
    jq -r '.[] | select (.Policies[0].Name == "terminating-gateway-terminating-gateway-token") | .AccessorID')

consul acl token update -id ${accessor_id} \
    -policy-name database-write-policy -merge-policies -merge-roles -merge-service-identities

kubectl apply -f consul-deployment/terminating-gateway/kubernetes.yaml