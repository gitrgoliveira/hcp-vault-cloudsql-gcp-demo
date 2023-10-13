variable "vault_address" {
  type = string
}

data "dns_a_record_set" "google" {
  host = replace(
    replace(
    trimsuffix(var.vault_address, "/"), ":8200", ""),
    "https://",
  "")
}

resource "google_sql_database_instance" "default" {
  provider = google-beta

  name             = "private-instance-${random_id.default.hex}"
  region           = "us-central1"
  database_version = "SQLSERVER_2022_ENTERPRISE"
  root_password    = random_password.default_root.result

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled = true

      dynamic "authorized_networks" {
        for_each = data.dns_a_record_set.google.addrs
        iterator = hcpv

        content {
          name  = "HCPVaultNode-${hcpv.key}"
          value = "${hcpv.value}/32"
        }
      }
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "default" {
  name            = "testdb"
  instance        = google_sql_database_instance.default.name
  deletion_policy = "DELETE"
}

resource "google_sql_user" "default" {
  name     = random_id.default.hex
  instance = google_sql_database_instance.default.name
  password = random_password.default.result
  type     = "BUILT_IN"
}
