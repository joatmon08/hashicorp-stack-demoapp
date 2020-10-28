setup: secrets-consul
	terraform init -backend-config=backend
	terraform apply

kubeconfig:
	aws eks --region $(shell terraform output region) update-kubeconfig --name $(shell terraform output eks_cluster_name)

secrets-consul:
	@printf "${CONSUL_HTTP_TOKEN}" > secrets/token
	@cat secrets/client_config.json | jq -j -r .encrypt > secrets/gossipEncryption
	@$(eval CONSUL_HOST := $(shell cat secrets/client_config.json | jq -r -j '.retry_join[0]'))
	@sed -i '.bak' 's/hcp_consul_host =.*/hcp_consul_host = "$(CONSUL_HOST)"/g' terraform.tfvars

configure-consul: kubeconfig
	kubectl create secret generic hcp-consul --from-file='caCert=./secrets/ca.pem' --from-file='gossipEncryptionKey=./secrets/gossipEncryption' || true
	kubectl create secret generic hcp-consul-bootstrap-token --from-file='token=./secrets/token' || true
	kubectl create secret generic consul-client-acl-token --from-file='token=./secrets/token' || true
	helm upgrade -i consul hashicorp/consul -f consul.yml

configure-vault:
	export VAULT_NAMESPACE=admin
	helm upgrade -i vault hashicorp/vault -f vault.yml
	cd kubernetes && terraform init -backend-config=backend
	cd kubernetes && terraform apply
	cd vault && terraform init -backend-config=backend
	echo "kubernetes_ca_cert = \"$(shell kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')\"" > vault/terraform.tfvars
	echo "kubernetes_host = \"$(shell kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}')\"" >> vault/terraform.tfvars
	echo "postgres_hostname = \"\"" >> vault/terraform.tfvars
	cd vault && terraform apply

configure-waypoint: kubeconfig
	waypoint install --platform=kubernetes -accept-tos

configure-boundary:
	echo "boundary_endpoint = \"$(shell terraform output boundary_endpoint)\"" > boundary/terraform.tfvars
	echo "boundary_kms_recovery_key_id = \"$(shell terraform output boundary_kms_recovery_key_id)\"" >> boundary/terraform.tfvars
	echo "eks_cluster_name = \"$(shell terraform output eks_cluster_name)\"" >> boundary/terraform.tfvars
	echo "region = \"$(shell terraform output region)\"" >> boundary/terraform.tfvars
	cd boundary && terraform init -backend-config=backend
	cd boundary && terraform apply

ssh:
	BOUNDARY_ADDR=$(shell cd boundary && terraform output boundary_endpoint) \
		boundary authenticate password -login-name=rosemary \
		-password $(shell cd boundary && terraform output boundary_password) \
		-auth-method-id=$(shell cd boundary && terraform output boundary_auth_method_id)
	BOUNDARY_ADDR=$(shell cd boundary && terraform output boundary_endpoint) \
		boundary connect ssh --username ec2-user -target-id $(shell cd boundary && terraform output boundary_target)

configure-db:
	waypoint init
	waypoint up -app database

configure-db-creds:
	@sed -i '.bak' 's/postgres_hostname =.*/postgres_hostname = "$(shell kubectl get services database -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")"/g' vault/terraform.tfvars
	cd vault && terraform init -backend-config=backend
	cd vault && terraform apply

configure-products:
	waypoint up -app products

configure-public:
	waypoint up -app public

configure-resolvers:
	kubectl apply -f consul/

configure-frontend:
	waypoint up -app frontend

clean-vault:
	cd vault && terraform destroy
	cd kubernetes && terraform destroy
	helm uninstall vault || true

clean-consul:
	helm uninstall consul || true
	kubectl delete jobs consul-server-acl-init consul-server-acl-init-cleanup || true
	kubectl delete secret hcp-consul hcp-consul-bootstrap-token consul-client-acl-token

clean-waypoint:
	waypoint destroy -app frontend
	waypoint destroy -app public
	waypoint destroy -app products
	waypoint destroy -app database
	kubectl delete -f consul/
	kubectl delete service waypoint --ignore-not-found
	kubectl delete statefulset waypoint-server --ignore-not-found

clean-boundary:
	cd boundary && terraform destroy

clean-setup:
	terraform destroy

clean: clean-waypoint clean-consul clean-vault clean-setup
