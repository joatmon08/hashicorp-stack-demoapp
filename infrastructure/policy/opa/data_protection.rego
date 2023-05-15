package terraform.policies.data_protection

import input.plan as plan

planned_values := plan.planned_values
resource_changes := plan.resource_changes

deny[msg] {
	outputs := planned_values.outputs
	plaintext_password_outputs := [key |
		outputs[key]
		contains(key, "password")
		not outputs[key].sensitive
	]
	count(plaintext_password_outputs) != 0
	msg := sprintf("%v should be marked as sensitive outputs", [plaintext_password_outputs])
}

deny[msg] {
	outputs := planned_values.outputs
	plaintext_token_outputs := [key |
		outputs[key]
		contains(key, "token")
		not outputs[key].sensitive
	]
	count(plaintext_token_outputs) != 0
	msg := sprintf("%v should be marked as sensitive outputs", [plaintext_token_outputs])
}

deny[msg] {
	r := resource_changes[_]
	r.type == "aws_db_instance"
	r.change.after.storage_encrypted == ""
	msg := sprintf("%v should have encrypted storage", [r.address])
}
