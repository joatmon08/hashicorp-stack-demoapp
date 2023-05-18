test-success:
	opa eval --input fixtures/success.json \
		--data opa/communication.rego \
		"data.terraform.policies.communication.deny" -f pretty
	opa eval --input fixtures/success.json \
		--data opa/configuration.rego \
		"data.terraform.policies.configuration.deny" -f pretty
	opa eval --input fixtures/success.json \
		--data opa/data_protection.rego \
		"data.terraform.policies.data_protection.deny" -f pretty
	opa eval --input fixtures/success.json \
		--data opa/inputs.rego \
		"data.terraform.policies.inputs.deny" -f pretty

test-fail:
	opa eval --input fixtures/fail.json \
		--data opa/communication.rego \
		"data.terraform.policies.communication.deny" -f pretty
	opa eval --input fixtures/fail.json \
		--data opa/configuration.rego \
		"data.terraform.policies.configuration.deny" -f pretty
	opa eval --input fixtures/fail.json \
		--data opa/data_protection.rego \
		"data.terraform.policies.data_protection.deny" -f pretty
	opa eval --input fixtures/fail.json \
		--data opa/inputs.rego \
		"data.terraform.policies.inputs.deny" -f pretty