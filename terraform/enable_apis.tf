# Enable required APIs
resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  project = var.project_id
  service = each.value
}

resource "null_resource" "apis_enabled" {
  depends_on = [google_project_service.enabled_apis]
}