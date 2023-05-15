policy "inputs" {
  query = "data.terraform.policies.inputs.deny"
  enforcement_level = "mandatory"
}

policy "communication" {
  query = "data.terraform.policies.communication.deny"
  enforcement_level = "advisory"
}

policy "data_protection" {
  query = "data.terraform.policies.data_protection.deny"
  enforcement_level = "mandatory"
}

policy "configuration" {
  query = "data.terraform.policies.configuration.deny"
  enforcement_level = "mandatory"
}