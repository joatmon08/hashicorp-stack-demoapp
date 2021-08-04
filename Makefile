fmt:
	cd vault && terraform fmt
	cd consul-deployment && terraform fmt
	cd boundary-configuration && terraform fmt
	cd boundary-deployment && terraform fmt
	cd infrastructure && terraform fmt
	cd kubernetes && terraform fmt
	terraform fmt

kubeconfig:
	aws eks --region $(shell cd infrastructure && terraform output -raw region) update-kubeconfig \
		--name $(shell cd infrastructure && terraform output -raw eks_cluster_name)

configure-db:
	boundary authenticate password -login-name=appdev \
		-password $(shell cd boundary-configuration && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output -raw boundary_auth_method_id)
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary-configuration && terraform output -raw boundary_target_postgres) -- -d products -f database-service/products.sql

configure-consul: kubeconfig
	consul acl token update -id \
		$(shell consul acl token list -format json |jq -r '.[] | select (.Policies[0].Name == "terminating-gateway-terminating-gateway-token") | .AccessorID') \
    	-policy-name database-write-policy -merge-policies -merge-roles -merge-service-identities
	kubectl apply -f consul-deployment/terminating_gateway.yaml

ssh-operations:
	@boundary authenticate password -login-name=ops \
		-password $(shell cd boundary-configuration && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output -raw boundary_auth_method_id)
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary-configuration && terraform output -raw boundary_target_eks) -- -i boundary-deployment/bin/id_rsa

ssh-products:
	@boundary authenticate password -login-name=appdev \
		-password $(shell cd boundary-configuration && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output -raw boundary_auth_method_id)
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary-configuration && terraform output -raw boundary_target_eks) -- -i boundary-deployment/bin/id_rsa

postgres-operations:
	@boundary authenticate password -login-name=ops \
		-password $(shell cd boundary-configuration && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output -raw boundary_auth_method_id)
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary-configuration && terraform output -raw boundary_target_postgres)

postgres-products:
	@boundary authenticate password -login-name=appdev \
		-password $(shell cd boundary-configuration && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output -raw boundary_auth_method_id)
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary-configuration && terraform output -raw boundary_target_postgres) -- -d products

configure-application:
	kubectl apply -f application/

clean-infrastructure:
	terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]'

clean-application:
	kubectl delete -f application/

clean-vault:
	vault lease revoke -force -prefix database/creds

clean-consul:
	kubectl delete -f consul-deployment/terminating_gateway.yaml

taint:
	cd consul-deployment && terraform taint hcp_consul_cluster_root_token.token

clean: clean-application clean-vault clean-consul taint

vault-commands:
	vault list sys/leases/lookup/database/creds/product
	vault read database/creds/product
	gunzip -d ~/Downloads/auditlogs-zero-202103231800-202103231900.gz

db-commands:
	psql -h 127.0.0.1 -p 62079 -U postgres -d products -f database-service/products.sql