output "consul_server_pki_path_root" {
  value = vault_mount.consul_pki.path
}

output "consul_server_pki_path_int" {
  value = vault_mount.consul_server_pki_int.path
}

output "consul_connect_pki_path_root" {
  value = vault_mount.consul_connect_pki.path
}

output "consul_connect_pki_path_int" {
  value = vault_mount.consul_connect_pki_int.path
}