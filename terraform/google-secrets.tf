# Enable Secret Manager API for the project


# Secret for db_user
resource "google_secret_manager_secret" "db_user_secret" {
  depends_on = [null_resource.apis_enabled] # Ensure the API is enabled first
  secret_id       = "db_user"
  replication {
      auto {}
  }
}

resource "google_secret_manager_secret_version" "db_user_secret_version" {
  secret      = google_secret_manager_secret.db_user_secret.id
  secret_data_wo = var.db_user
}

# Secret for db_password
resource "google_secret_manager_secret" "db_password_secret" {
  depends_on = [null_resource.apis_enabled]# Ensure the API is enabled first
  secret_id       = "db_password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data_wo = var.db_password
}