export BOUNDARY_ADDR=$(cd boundary && terraform output -raw boundary_endpoint)
export PGPASSWORD=$(cd infrastructure && terraform output -raw product_database_password)
export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_address)
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_token)
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -raw hcp_vault_namespace)
export CONSUL_HTTP_ADDR=$(cd consul/setup && terraform output -raw consul_address)
export CONSUL_HTTP_TOKEN=$(cd consul/setup && terraform output -raw consul_token)
export CONSUL_HTTP_SSL_VERIFY=false