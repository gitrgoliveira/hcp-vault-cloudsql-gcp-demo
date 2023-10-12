resource "random_id" "default" {
  byte_length = 4
}

resource "random_uuid" "default" {}
resource "random_password" "default_root" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "random_password" "default" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}