resource "vault_mount" "mongo" {
  path        = "mongodbatlas"
  type        = "mongodbatlas"
  description = "MongoDB Atlas secret engine mount"
}

resource "vault_mongodbatlas_secret_backend" "config" {
  count       = var.mongodbatlas_public_key != null ? 1 : 0
  mount       = vault_mount.mongo.path
  private_key = var.mongodbatlas_private_key
  public_key  = var.mongodbatlas_public_key
}

resource "vault_mongodbatlas_secret_role" "role" {
  for_each   = toset(keys(var.tfc_team_ids))
  mount      = vault_mount.mongo.path
  name       = each.value
  project_id = var.mongodbatlas_project_id
  roles      = ["GROUP_OWNER"]
  ttl        = "3600"
  max_ttl    = "7200"
}

resource "vault_policy" "mongodbatlas_creds" {
  for_each = toset(keys(var.tfc_team_ids))
  name     = "mongodbatlas-creds-${each.value}"
  policy   = <<EOT
path "${vault_mount.mongo.path}/creds/${each.value}" {
  capabilities = [ "read" ]
}
EOT
}

resource "mongodbatlas_project_ip_access_list" "allow_tfc" {
  project_id = var.mongodbatlas_project_id
  cidr_block = "0.0.0.0/0"
  comment    = "cidr block for Terraform configuration"
}