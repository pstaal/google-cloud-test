# Create a new dedicated service account for Cloud Run
resource "google_service_account" "rommelproject_cloud_run_sa" {
  account_id   = "rommelproject-cloud-run-sa"           # Customize the account ID
  display_name = "RommelProject Cloud Run Service Account"
}

resource "google_project_iam_member" "cloud_run_sql_access" {
  project = var.project_id
  role    = "roles/cloudsql.client"                   # Cloud SQL Client role
  member  = "serviceAccount:${google_service_account.rommelproject_cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_run_vpc_access" {
  project = var.project_id
  role    = "roles/compute.networkUser"               # Compute Network User role
  member  = "serviceAccount:${google_service_account.rommelproject_cloud_run_sa.email}"
}

resource "google_cloud_run_service" "rommelproject_cloud_run" {
  name     = "rommelproject-cloud-run"                  # Name of the service
  location = "europe-west1"                             # Same region as your VPC and Cloud SQL

  template {
    spec {
      service_account_name = google_service_account.rommelproject_cloud_run_sa.email

      containers {
        # Specify the Docker image for your Cloud Run service
        image = "gcr.io/${var.project_id}/your-cloud-run-app" # Replace with your Cloud Run Docker image

        # Pass database connection and private IP as environment variables to the container
        env {
          name  = "DB_CONNECTION_NAME"
          value = google_sql_database_instance.db_instance.connection_name
        }
        env {
          name  = "DB_PRIVATE_IP"
          value = google_sql_database_instance.db_instance.private_ip_address
        }
      }

      # Configure Cloud Run to use the VPC subnet for private networking
      vpc_access {
        subnet = google_compute_subnetwork.rommelproject_subnet.name # Reference the existing subnet
        egress = "PRIVATE_RANGES_ONLY"                              # Restrict outbound traffic to private IPs
      }
    }
  }

  # Allow traffic only from internal/private sources
  ingress = "internal"

  # Automatically generate revision names when deploying updates
  autogenerate_revision_name = true
}


