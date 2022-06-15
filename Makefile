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

configure-kubernetes:
	kubectl apply --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.2.1"

configure-api-gateway:
	kubectl patch deployment consul-api-gateway-controller -p '{"spec": {"template":{"metadata":{"annotations":{"vault.hashicorp.com/namespace":"admin"}}}}}'

configure-certs-spiffe:
	bash certs/reconfigure.sh

configure-terminating-gateway:
	kubectl apply -f application/intentions.yaml
	bash consul/config/configure.sh

configure-db: boundary-appdev-auth
	bash database/configure.sh

configure-cts:
	kubectl apply -f consul/cts/kubernetes.yaml

configure-application:
	kubectl apply -f application/product-api.yaml
	kubectl rollout status deployment product
	kubectl apply -f application/payments.yaml
	kubectl apply -f application/public-api.yaml
	kubectl apply -f application/frontend.yaml
	kubectl apply -f application/nginx.yaml

configure-route:
	kubectl apply -f application/route.yaml

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
	vault lease revoke -force -prefix database/product/creds

clean-cts:
	bash consul/cts/clean.sh

clean-consul:
	kubectl patch gatewayclasses.gateway.networking.k8s.io consul-api-gateway --type merge --patch '{"metadata":{"finalizers":[]}}'
	kubectl patch gatewayclassconfigs.api-gateway.consul.hashicorp.com consul-api-gateway --type merge --patch '{"metadata":{"finalizers":[]}}'

clean-kubernetes:
	kubectl delete --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.2.1"

clean-certs:
	cd certs/terraform && terraform destroy -auto-approve -var="signed_cert=true"
	rm -rf certs/connect/ certs/gateway/ certs/server/ certs/new_config.json

vault-commands:
	vault read database/product/config/product

consul-commands:
	curl -k -H "X-Consul-Token:${CONSUL_HTTP_TOKEN}" ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots | jq .

db-commands:
	psql -h 127.0.0.1 -p 62079 -U postgres -d products -f database-service/products.sql