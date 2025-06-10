# Set secret names based on the environment
locals {
  db_user_secret    = "db_user"
  db_password_secret = "db_password"
}

# Read the db_user secret from Google Secret Manager
data "google_secret_manager_secret" "db_user_secret" {
  secret_id = local.db_user_secret
  project   = var.project_id

  # Ensure the secrets are created before this resource
  depends_on = [
    google_secret_manager_secret_version.db_user_secret_version,
    google_secret_manager_secret_version.db_password_secret_version
  ]
}

data "google_secret_manager_secret_version" "db_user_secret_version" {
  secret = data.google_secret_manager_secret.db_user_secret.id
  version = "latest" # Or specify a version number
}

# Read the db_password secret from Google Secret Manager
data "google_secret_manager_secret" "db_password_secret" {
  secret_id = local.db_password_secret
  project   = var.project_id

  # Ensure the secrets are created before this resource
  depends_on = [
    google_secret_manager_secret_version.db_user_secret_version,
    google_secret_manager_secret_version.db_password_secret_version
  ]
}

data "google_secret_manager_secret_version" "db_password_secret_version" {
  secret = data.google_secret_manager_secret.db_password_secret.id
  version = "latest" # Or specify a version number
}

# Allocate a private IP range (required for private IP connection)
resource "google_compute_global_address" "private_ip_range" {
  depends_on = [null_resource.apis_enabled, google_compute_network.rommelproject_vpc]
  name          = "cloud-sql-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.rommelproject_vpc.self_link
}

# Establish private service networking connection
resource "google_service_networking_connection" "private_connection" {
  depends_on = [null_resource.apis_enabled, google_compute_network.rommelproject_vpc, google_compute_global_address.private_ip_range]
  network                 = google_compute_network.rommelproject_vpc.self_link # Reference existing VPC
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

# Create a Cloud SQL instance with private IP
resource "google_sql_database_instance" "db_instance" {
  depends_on = [null_resource.apis_enabled, google_compute_network.rommelproject_vpc, google_service_networking_connection.private_connection]
  name             = "private-sql-instance"
  project          = var.project_id
  region           = "europe-west1"
  database_version = "POSTGRES_15"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    availability_type = "ZONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.rommelproject_vpc.self_link # Reference existing VPC
    }
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "off"
    }
  }
}

# Create a separate database in the SQL instance
resource "google_sql_database" "db" {
  name     = "${var.environment}_example_db"
  instance = google_sql_database_instance.db_instance.name
  depends_on = [google_sql_database_instance.db_instance]
}

# Create a SQL user with credentials from Secret Manager
resource "google_sql_user" "user" {
  name     = data.google_secret_manager_secret_version.db_user_secret_version.secret_data
  instance = google_sql_database_instance.db_instance.name
  password = data.google_secret_manager_secret_version.db_password_secret_version.secret_data

  # Ensure the secrets are created before this resource
  depends_on = [
    google_sql_database_instance.db_instance,
    google_service_networking_connection.private_connection,
    google_secret_manager_secret_version.db_user_secret_version,
    google_secret_manager_secret_version.db_password_secret_version,
  ]
}
