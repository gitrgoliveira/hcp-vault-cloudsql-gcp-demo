provider "vault" {
  address   = var.vault_address
  namespace = "admin"
}

resource "vault_namespace" "demo" {
  path = "demo_${random_id.default.hex}"
}

resource "vault_mount" "database_mssql" {
  namespace = vault_namespace.demo.path_fq
  path      = format("%s/database/mssql", google_sql_database_instance.default.name)
  type      = "database"
}

resource "vault_database_secret_backend_connection" "cloudsql" {
  namespace     = vault_namespace.demo.path_fq
  backend       = vault_mount.database_mssql.path
  name          = google_sql_database_instance.default.name
  allowed_roles = ["dev", google_sql_user.default.name]
  plugin_name   = "mssql-database-plugin"

  mssql {
    connection_url = "sqlserver://{{username}}:{{password}}@${google_sql_database_instance.default.ip_address.0.ip_address}:1433"
    username       = "sqlserver"
    password       = random_password.default_root.result
    # username       = google_sql_user.default.name
    # password = google_sql_user.default.password
  }
}

resource "vault_database_secret_backend_role" "default" {
  namespace = vault_namespace.demo.path_fq
  backend   = vault_mount.database_mssql.path
  name      = "dev"
  db_name   = vault_database_secret_backend_connection.cloudsql.name
  creation_statements = [
    "USE [${google_sql_database.default.name}];",
    "CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}';",
    "CREATE USER [{{name}}] FOR LOGIN [{{name}}];",
    "EXEC sp_addrolemember db_datareader, [{{name}}];",
  ]
  revocation_statements = [
    "USE [${google_sql_database.default.name}];",
    "DROP LOGIN [{{name}}];"
  ]
}

# resource "vault_generic_endpoint" "rotate_initial_db_password" {
#   depends_on     = [vault_database_secret_backend_connection.cloudsql]
#   namespace      = vault_namespace.demo.path_fq
#   path           = "${vault_mount.database_mssql.path}/rotate-root/${vault_database_secret_backend_connection.cloudsql.name}"
#   disable_read   = true
#   disable_delete = true

#   data_json = "{}"
# }

# configure a static role with period-based rotations
# resource "vault_database_secret_backend_static_role" "static_role" {
#   namespace = vault_namespace.demo.path_fq
#   backend   = vault_mount.database_mssql.path
#   name                = google_sql_user.default.name
#   db_name   = vault_database_secret_backend_connection.cloudsql.name
#   username            = google_sql_user.default.name
#   rotation_period     = "3600"
#   rotation_statements = ["ALTER USER [{{name}}] WITH PASSWORD = '{{password}}';"]
# }
