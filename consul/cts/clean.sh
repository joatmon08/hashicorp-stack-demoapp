#!/bin/bash

set -e

POD=$(kubectl get pod -l app=consul-terraform-sync -o jsonpath="{.items[0].metadata.name}")

kubectl exec -c consul-terraform-sync -it ${POD} -- /bin/consul-terraform-sync task disable products-database
kubectl exec -c consul-terraform-sync -it ${POD} -- /bin/sh -c 'cd /consul-terraform-sync/sync-tasks/products-database && source /vault/secrets/auth && VAULT_TOKEN=$(cat /vault/secrets/token) /consul-terraform-sync/terraform destroy'
kubectl exec -c consul-terraform-sync -it ${POD} -- /bin/consul-terraform-sync task delete products-database