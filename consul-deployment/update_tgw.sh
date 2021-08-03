#!/bin/bash

accessor_id=$(consul acl token list -format json | \
    jq -r '.[] | select (.Policies[0].Name == "terminating-gateway-terminating-gateway-token") | .AccessorID')

consul acl token update -id ${accessor_id} \
    -policy-name database-write-policy -merge-policies -merge-roles -merge-service-identities

kubectl apply -f update_tgw.yaml