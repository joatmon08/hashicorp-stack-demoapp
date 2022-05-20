export BOUNDARY_ADDR=$(cd boundary && terraform output -raw boundary_endpoint)
export CONSUL_HTTP_ADDR=$(cd infrastructure && terraform output -raw hcp_consul_public_address)
export CONSUL_HTTP_TOKEN=$(cd consul-deployment && terraform output -raw hcp_consul_token)
export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=admin