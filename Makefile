fmt:
	cd vault/setup && terraform fmt
	cd vault/app && terraform fmt
	cd consul && terraform fmt
	cd boundary/setup && terraform fmt
	cd boundary/setup-deployment && terraform fmt
	cd infrastructure && terraform fmt
	cd kubernetes && terraform fmt
	terraform fmt

kubeconfig:
	aws eks --region $(shell cd infrastructure && terraform output -raw region) \
		update-kubeconfig \
		--name $(shell cd infrastructure && terraform output -raw eks_cluster_name)

get-ssh:
	rm -rf secrets
	mkdir -p secrets
	cd infrastructure && terraform output -raw boundary_worker_ssh | base64 -d > ../secrets/id_rsa.pem
	chmod 400 secrets/id_rsa.pem

configure-certs:
	bash certs/ca_root.sh

configure-hcp-certs:
	bash certs/reconfigure.sh

configure-consul:
	bash consul/config/configure.sh

configure-tfc:
	kubectl apply -f argocd/applications/terraform-operator/

configure-application:
	kubectl apply -f argocd/applications/promotions.yaml
	kubectl apply -f argocd/applications/payments-app.yaml

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
	@echo "$(shell cd boundary/setup && terraform output -raw boundary_operations_password)" > secrets/ops
	boundary authenticate password -login-name=ops \
		-password file://secrets/ops \
		-auth-method-id=$(shell cd boundary/setup && terraform output -raw boundary_auth_method_id)

boundary-appdev-auth:
	mkdir -p secrets
	@echo "$(shell cd boundary/setup && terraform output -raw boundary_products_password)" > secrets/appdev
	boundary authenticate password -login-name=appdev \
		-password file://secrets/appdev \
		-auth-method-id=$(shell cd boundary/setup && terraform output -raw boundary_auth_method_id)

ssh-k8s-nodes:
	boundary connect ssh -username=ec2-user -target-name eks_nodes_ssh -target-scope-name core_infra -- -i secrets/id_rsa.pem

postgres-operations:
	boundary connect postgres \
		-username=$(shell vault kv get -field=username payments-app/static/payments) \
		-dbname=payments -target-name payments-app-database-postgres -target-scope-name=products_infra

frontend-products:
	boundary connect -target-id \
		$(shell cd boundary/setup && terraform output -raw boundary_target_frontend)

clean-application:
	kubectl delete -f argocd/applications/

clean-tfc:
	kubectl delete app terraform-cloud-operator -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
	kubectl delete app terraform-cloud-operator -n argocd

clean-consul:
	kubectl patch app consul-api-gateway -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
	kubectl delete app consul-api-gateway -n argocd
	kubectl patch app consul-defaults -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
	kubectl delete app consul-defaults -n argocd
	kubectl patch app consul-config -n argocd -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
	kubectl delete app consul-config -n argocd

clean-vault:
	vault lease revoke -force -prefix database/product/creds

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

terraform-upgrade:
	cd infrastructure && terraform init -upgrade
	cd boundary/setup && terraform init -upgrade
	cd argocd && terraform init -upgrade
	cd vault/setup && terraform init -upgrade
	cd vault/consul && terraform init -upgrade
	cd consul/setup && terraform init -upgrade

terraform-test:
	bash database/run_tests.sh

terraform-test-fixture:
	curl --header "Content-Type: application/vnd.api+json" --header "Authorization: Bearer ${TF_TOKEN}" --location https://app.terraform.io/api/v2/plans/${TF_PLAN_ID}/json-output > infrastructure/policy/fixtures/terraform.json

run-module:
	kubectl patch module database -n promotions --type=merge --patch '{"spec": {"restartedAt": "'`date -u -Iseconds`'"}}'

test-promotions:
	curl -k -H "Host:gateway.hashiconf.example.com" https://$(shell kubectl get svc -n consul api-gateway -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")