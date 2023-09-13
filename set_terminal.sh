export BOUNDARY_ADDR=$(cd infrastructure && terraform output -raw hcp_boundary_endpoint)
export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -raw hcp_vault_namespace)
export CONSUL_HTTP_ADDR=$(cd infrastructure && terraform output -raw hcp_consul_public_address)
export CONSUL_HTTP_TOKEN=$(cd infrastructure && terraform output -raw hcp_consul_token)

export ARGOCD_AUTH_TOKEN=$(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)