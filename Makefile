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

configure-hcp-certs:
	bash certs/reconfigure.sh

configure-kubernetes:
	kubectl apply --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.4.0"

configure-terminating-gateway:
	bash consul/config/configure.sh

configure-db: boundary-appdev-auth
	bash database/configure.sh

hashicups:
	kubectl apply -f application/hashicups/intentions.yaml
	kubectl apply -f application/hashicups/product-api.yaml
	kubectl rollout status deployment product
	kubectl apply -f application/hashicups/payments.yaml
	kubectl rollout status deployment payments
	kubectl apply -f application/hashicups/public-api.yaml
	kubectl rollout status deployment public
	kubectl apply -f application/hashicups/frontend.yaml
	kubectl rollout status deployment frontend
	kubectl apply -f application/hashicups/nginx.yaml
	kubectl rollout status deployment nginx
	kubectl apply -f application/hashicups/route.yaml

clean-hashicups:
	kubectl delete -f application/hashicups/

expense-report:
	kubectl apply -f application/expense-report/intentions.yaml
	kubectl apply -f application/expense-report/expense.yaml
	kubectl rollout status deployment expense
	kubectl apply -f application/expense-report/report.yaml
	kubectl rollout status deployment report
	kubectl apply -f application/expense-report/route.yaml
	kubectl apply -f application/expense-report/reconciliation.yaml
	kubectl rollout status deployment reconciliation

clean-expense-report:
	kubectl delete -f application/expense-report/

clean-applications: clean-expense-report clean-hashicups

boundary-operations-auth:
	mkdir -p secrets
	@echo $(shell cd boundary && terraform output -raw boundary_operations_password) > secrets/ops
	boundary authenticate password -login-name=ops \
		-password file://secrets/ops \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

boundary-appdev-auth:
	mkdir -p secrets
	@echo $(shell cd boundary && terraform output -raw boundary_products_password) > secrets/appdev
	boundary authenticate password -login-name=appdev \
		-password file://secrets/appdev \
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
	curl -k -H "X-Consul-Token:${CONSUL_HTTP_TOKEN}" ${CONSUL_HTTP_ADDR}/v1/connect/ca/roots | jq -r '.Roots[0].RootCert' > tmp.crt
	openssl x509 -noout -text -in tmp.crt

db-commands:
	psql -h 127.0.0.1 -p 62079 -U postgres -d products -f database-service/products.sql