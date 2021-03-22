fmt:
	cd vault && terraform fmt
	cd consul-deployment && terraform fmt
	cd boundary-configuration && terraform fmt
	cd boundary-deployment && terraform fmt
	cd infrastructure && terraform fmt
	cd kubernetes && terraform fmt
	terraform fmt

kubeconfig:
	aws eks --region $(shell cd infrastructure && terraform output region) update-kubeconfig \
		--name $(shell cd infrastructure && terraform output eks_cluster_name)

configure-db:
	boundary authenticate password -login-name=rob \
		-password $(shell cd boundary-configuration && terraform output boundary_products_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output boundary_auth_method_id)
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary-configuration && terraform output boundary_target_postgres) -- -d products -f database-service/products.sql

configure-consul:
	bash consul-deployment/terminating-gateway/update.sh

helm-vault:
	export VAULT_NAMESPACE=admin
	helm upgrade --install vault hashicorp/vault --set injector.enabled=true --set injector.externalVaultAddr=${VAULT_PRIVATE_ADDR}

configure-vault:
	cd vault && terraform init
	echo "kubernetes_host = \"$(shell kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}')\"" >> vault/terraform.tfvars
	cd vault && terraform init && terraform apply cd vault && terraform init \
		&& terraform apply -var postgres_hostname=$(shell cd infrastructure && terraform output -raw product_database_address) \
		-var postgres_password=${PGPASSWORD}

ssh-operations:
	@boundary authenticate password -login-name=rosemary \
		-password $(shell cd boundary-configuration && terraform output boundary_operations_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output boundary_auth_method_id)
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary-configuration && terraform output boundary_target_eks) -- -i boundary-deployment/bin/id_rsa

ssh-products:
	@boundary authenticate password -login-name=rob \
		-password $(shell cd boundary-configuration && terraform output boundary_products_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output boundary_auth_method_id)
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary-configuration && terraform output boundary_target_eks) -- -i boundary-deployment/bin/id_rsa

postgres-operations:
	@boundary authenticate password -login-name=rosemary \
		-password $(shell cd boundary-configuration && terraform output boundary_operations_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output boundary_auth_method_id)
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary-configuration && terraform output boundary_target_postgres)

postgres-products:
	@boundary authenticate password -login-name=rob \
		-password $(shell cd boundary-configuration && terraform output boundary_products_password) \
		-auth-method-id=$(shell cd boundary-configuration && terraform output boundary_auth_method_id)
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary-configuration && terraform output boundary_target_postgres)

configure-application:
	kubectl apply -f application/

clean-application:
	kubectl delete -f application/

clean-vault:
	vault lease revoke -force -prefix database/creds

clean: clean-application clean-vault
