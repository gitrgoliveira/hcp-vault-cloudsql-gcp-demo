output "vault_ip" {
  value = data.dns_a_record_set.google.addrs
}

output "vault_namespace" {
  value = vault_namespace.demo.path_fq
}
output "vault_mssql_role" {
  value = vault_database_secret_backend_role.default.id
}
output "vault_command" {
  value = "vault read -namespace=admin/${vault_namespace.demo.path_fq} ${vault_mount.database_mssql.path}/creds/${vault_database_secret_backend_role.default.name}"
}
# output "vault_mssql_static_role" {
#   value = vault_database_secret_backend_static_role.static_role.id
# }

# output "vault_command2" {
#   value = "vault read -namespace=admin/${vault_namespace.demo.path_fq} ${replace(vault_database_secret_backend_static_role.static_role.id, "roles", "creds")}"
# }