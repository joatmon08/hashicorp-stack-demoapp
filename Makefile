fmt:
	cd vault && terraform fmt
	cd consul-deployment && terraform fmt
	cd boundary && terraform fmt
	cd boundary-deployment && terraform fmt
	cd infrastructure && terraform fmt
	cd kubernetes && terraform fmt
	terraform fmt

kubeconfig:
	aws eks --region $(shell cd infrastructure && terraform output -raw region) update-kubeconfig \
		--name $(shell cd infrastructure && terraform output -raw eks_cluster_name)

configure-consul: kubeconfig
	consul acl token update -id \
		$(shell consul acl token list -format json |jq -r '.[] | select (.Policies[0].Name == "terminating-gateway-terminating-gateway-token") | .AccessorID') \
    	-policy-name database-write-policy -merge-policies -merge-roles -merge-service-identities
	kubectl apply -f consul-deployment/terminating_gateway.yaml

boundary-operations-auth:
	@boundary authenticate password -login-name=ops \
		-password $(shell cd boundary && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

boundary-appdev-auth:
	@boundary authenticate password -login-name=appdev \
		-password $(shell cd boundary && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

ssh-operations:
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_eks) -- -i ${SSH_KEYPAIR_FILE}

ssh-products:
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_eks) -- -i ${SSH_KEYPAIR_FILE}

configure-db:
	boundary connect postgres -username=$(shell cd infrastructure && terraform output -raw product_database_username) -dbname=products -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres) -- -f database/products.sql

postgres-operations:
	boundary connect postgres -username=$(shell cd infrastructure && terraform output -raw product_database_username) -dbname=products -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres)

frontend-products:
	boundary connect -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_frontend)

configure-application:
	kubectl apply -f application/

get-application:
	kubectl get svc frontend -o jsonpath="{.status.loadBalancer.ingress[*].hostname}"

clean-infrastructure:
	terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]'

clean-application:
	kubectl delete -f application/

clean-vault:
	vault lease revoke -force -prefix database/creds

clean-consul:
	kubectl delete -f consul-deployment/terminating_gateway.yaml

clean: clean-application clean-vault clean-consul

vault-commands:
	vault list sys/leases/lookup/database/creds/product
	kubectl exec -it $(shell kubectl get pods -l="app=product" -o name) -- cat /vault/secrets/conf.json

db-commands:
	psql -h 127.0.0.1 -p 62079 -U postgres -d products -f database-service/products.sql