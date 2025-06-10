# Maak een service-account voor Cloud Run met toegang tot de Cloud SQL instance
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

# Geef noodzakelijke machtigingen om Cloud Run te beheren
resource "google_project_iam_binding" "run_admin_role" {
  project = var.project_id
  role    = "roles/run.admin"
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
  depends_on = [google_cloud_run_service.cloud_run_backend]
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

# Grant Service Account permissions to manage resources
resource "google_project_iam_binding" "service_usage_admin" {
  project = var.project_id # Replace with your project ID

  role   = "roles/serviceusage.serviceUsageAdmin" # Permission to enable APIs
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
}

resource "google_project_iam_binding" "compute_network_user" {
  project = var.project_id # Replace with your project ID

  role   = "roles/compute.networkUser" # Permission for VPC network access (if needed)
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
}

resource "google_project_iam_binding" "iam_service_account_user" {
  project = var.project_id # Replace with your project ID

  role   = "roles/iam.serviceAccountUser" # Permission to use the service account
  members = ["serviceAccount:${google_service_account.cloud_run_sa.email}"]
}