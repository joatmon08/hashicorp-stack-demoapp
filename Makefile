fmt:
	cd vault/setup && terraform fmt
	cd vault/app && terraform fmt
	cd consul && terraform fmt
	cd boundary && terraform fmt
	cd boundary-deployment && terraform fmt
	cd infrastructure && terraform fmt
	cd kubernetes && terraform fmt
	terraform fmt

kubeconfig:
	aws eks --region $(shell cd infrastructure && terraform output -raw region) \
		update-kubeconfig \
		--name $(shell cd infrastructure && terraform output -raw eks_cluster_name)

configure-certs:
	bash certs/ca_root.sh

configure-consul:
	bash consul/database/configure.sh

configure-db: boundary-appdev-auth
	bash database/configure.sh

configure-application:
	kubectl apply -f application/

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

postgres-operations: boundary-appdev-auth
	boundary connect postgres \
		-username=$(shell cd infrastructure && terraform output -raw product_database_username) \
		-dbname=products -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres)

frontend-products:
	boundary connect -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_frontend)

clean-application:
	kubectl delete -f application/

clean-vault:
	vault lease revoke -force -prefix database/creds

clean-consul:
	bash consul/database/clean.sh

clean-certs:
	cd certs/terraform && terraform destroy -auto-approve -var="signed_cert=true"
	rm -rf certs/root/ certs/intermediate/

vault-commands:
	vault list sys/leases/lookup/database/creds/product
	kubectl exec -it $(shell kubectl get pods -l="app=product" -o name) -- cat /vault/secrets/conf.json

db-commands:
	psql -h 127.0.0.1 -p 62079 -U postgres -d products -f database-service/products.sql