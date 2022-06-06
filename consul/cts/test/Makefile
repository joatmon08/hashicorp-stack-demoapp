install:
	helm upgrade --install consul hashicorp/consul --values consul.yaml
	helm upgrade --install vault hashicorp/vault --values vault.yaml
	kubectl apply -f database.yaml

init:
	cd terraform && terraform init
	cd terraform && terraform apply

deploy:
	kubectl apply -f cts.yaml
	kubectl apply -f product-api.yaml

clean:
	bash clean.sh
