package terraform.policies.inputs

import input.plan as tfplan

deny[msg] {
	r := tfplan.variables
	r.aws_access_key_id
	msg := "do not define AWS access key as part of variables, use AWS_ACCESS_KEY_ID environment variable instead"
}

deny[msg] {
	r := tfplan.variables
	r.aws_secret_access_key
	msg := "do not define AWS secret access key as part of variables, use AWS_SECRET_ACCESS_KEY environment variable instead"
}

deny[msg] {
	r := tfplan.variables
	r.hcp_client_id
	msg := "do not define HCP client ID as part of variables, use HCP_CLIENT_ID environment variable instead"
}

deny[msg] {
	r := tfplan.variables
	r.hcp_client_secret
	msg := "do not define HCP client secret as part of variables, use HCP_CLIENT_SECRET environment variable instead"
}

deny[msg] {
	r := tfplan.variables
	"0.0.0.0/0" == r.client_cidr_block.value[i]
	msg := "do not define 0.0.0.0/0 in client CIDR block, use specific IP address range"
}