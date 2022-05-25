export CONSUL_HTTP_ADDR=https://$(kubectl get svc consul-ui --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export CONSUL_HTTP_TOKEN=$(vault kv get -field=token consul/static/bootstrap)
export CONSUL_HTTP_SSL_VERIFY=false