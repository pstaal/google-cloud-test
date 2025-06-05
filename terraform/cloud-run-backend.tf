# Maak een service-account voor Cloud Run met toegang tot de Cloud SQL instance
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

# Toewijzen van de "Cloud SQL Client" rol aan het service-account
resource "google_project_iam_binding" "cloud_sql_client_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
}

# Toewijzen van de "Artifact Registry Reader" rol aan het service-account
resource "google_project_iam_binding" "artifact_registry_reader_role" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
}

# Toewijzen van de "Storage Object Viewer" rol voor Google Container Registry (GCR)
resource "google_project_iam_binding" "storage_object_viewer_role" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
}

# Maak de Cloud Run service
resource "google_cloud_run_service" "cloud_run_backend" {
  name     = "cloud-run-backend-service"
  location = "europe-west1" # Zorg dat dit overeenkomt met de regio van je Cloud SQL-database en VPC

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal" # Beperk toegang via privé-ingress
    }
  }

  template {
    spec {
      containers {
        image = "gcr.io/rommelproject1/backend-image" # Vervang met de juiste container image URL
        env {
          name  = "TYPEORM_HOST"
          value = google_sql_database_instance.db_instance.private_ip_address # Cloud SQL Private IP
        }
        env {
          name  = "TYPEORM_PORT"
          value = "5432"
        }
        env {
          name  = "TYPEORM_USERNAME"
          value = data.google_secret_manager_secret_version.db_user_secret_version.secret_data # Vul de juiste databasegebruikersnaam in
        }
        env {
          name  = "TYPEORM_PASSWORD"
          value = data.google_secret_manager_secret_version.db_password_secret_version.secret_data # Vul het bijbehorende wachtwoord in
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/egress-settings"     = "all" # Forceer alle egress via VPC
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.db_instance.connection_name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_secret_manager_secret_version.db_user_secret_version,
    google_secret_manager_secret_version.db_password_secret_version,
    google_service_account.cloud_run_sa,
    google_sql_database_instance.db_instance,
  ]
}

# Geef noodzakelijke machtigingen om Cloud Run te beheren
resource "google_project_iam_binding" "run_admin_role" {
  project = var.project_id
  role    = "roles/run.admin"
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
  depends_on = [google_cloud_run_service.cloud_run_backend]
}


