resource "tfe_variable_set" "mongodb" {
  count        = var.mongodb_atlas != null ? 1 : 0
  name         = "MongoDB Atlas"
  description  = "Variables for MongoDB Atlas"
  organization = tfe_organization.demo.name
  global       = false
}

resource "tfe_variable" "mongodb_public_key" {
  count           = var.mongodb_atlas != null ? 1 : 0
  key             = "mongodbatlas_public_key"
  value           = var.mongodb_atlas.public_key
  category        = "terraform"
  description     = "MongoDB Atlas public key"
  variable_set_id = tfe_variable_set.mongodb.0.id
}

resource "tfe_variable" "mongodb_private_key" {
  count           = var.mongodb_atlas != null ? 1 : 0
  key             = "mongodbatlas_private_key"
  value           = var.mongodb_atlas.private_key
  category        = "terraform"
  description     = "MongoDB Atlas private key"
  variable_set_id = tfe_variable_set.mongodb.0.id
  sensitive       = true
}

resource "tfe_variable" "mongodb_project_id" {
  count           = var.mongodb_atlas != null ? 1 : 0
  key             = "mongodbatlas_project_id"
  value           = var.mongodb_atlas.project_id
  category        = "terraform"
  description     = "MongoDB Atlas project ID"
  variable_set_id = tfe_variable_set.mongodb.0.id
}

resource "tfe_variable" "mongodb_region" {
  count           = var.mongodb_atlas != null ? 1 : 0
  key             = "mongodbatlas_region"
  value           = upper(replace(var.region, "-", "_"))
  category        = "terraform"
  description     = "MongoDB Atlas provider region"
  variable_set_id = tfe_variable_set.mongodb.0.id
}