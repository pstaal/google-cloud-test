
# Hosting frontend op Cloud Run
resource "google_cloud_run_service" "cloud_run_frontend" {
  name     = "cloud-run-frontend-service"
  location = "europe-west1" # Gebruik dezelfde regio als je backend en CDN

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "all" # Publieke toegang via Cloud CDN
    }
  }

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email # Service-account voor frontend

      containers {
        image = "europe-west1-docker.pkg.dev/rommelproject1/test-docker/frontend-image" # Vervang met de juiste container image URL voor de frontend
        env {
          name  = "VITE_BACKEND_URL" # Backend URL beschikbaar als omgevingsvariabele
          value = google_cloud_run_service.cloud_run_backend.status[0].url
        }
        env {
          name  = "VITE_PORT" # Optional - Use if specifically needed
          value = "8080"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_service_account.cloud_run_sa,
    null_resource.apis_enabled,
    google_project_iam_binding.artifact_registry_reader_role,
    google_project_iam_binding.run_admin_role,
    google_project_iam_binding.storage_object_viewer_role,
    google_project_iam_binding.iam_service_account_user,
    google_project_iam_binding.compute_network_user,
    google_project_iam_binding.service_usage_admin,
    google_cloud_run_service.cloud_run_backend, # Zorg dat het backend beschikbaar is!!
  ]
}

resource "google_cloud_run_service_iam_member" "frontend_public_access" {
  service  = google_cloud_run_service.cloud_run_frontend.name # Your frontend service
  location = google_cloud_run_service.cloud_run_frontend.location

  role    = "roles/run.invoker" # Allows invocation
  member  = "allUsers" # Grant access to any user (anonymous/public access)
  depends_on = [google_cloud_run_service.cloud_run_frontend]
}

# Cloud CDN inzetten met Cloud Run Frontend
# ----------- Maak een Serverless NEG (Network Endpoint Group) -----------
resource "google_compute_region_network_endpoint_group" "cloud_run_frontend_neg" {
  name                  = "cloud-run-frontend-neg"
  region  = "europe-west1" # Zorg dat de regio overeenkomt
  network_endpoint_type = "SERVERLESS" # Geef aan dat dit een serverless NEG is

  cloud_run {
    service = google_cloud_run_service.cloud_run_frontend.name # Koppeling met Cloud Run
  }

  depends_on = [google_cloud_run_service.cloud_run_frontend]
}

# ----------- Backend Service voor Cloud CDN (met Serverless NEG) -----------
resource "google_compute_backend_service" "frontend_cdn_backend" {
  name        = "frontend-cdn-backend"
  protocol    = "HTTP" # Protocol voor de service
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_frontend_neg.id # Verwijzing naar de NEG
  }

  cdn_policy {
    cache_key_policy {
      include_protocol    = true
      include_host        = true
      include_query_string = true
    }
  }

  enable_cdn = true # Schakel Cloud CDN in

  depends_on = [google_compute_region_network_endpoint_group.cloud_run_frontend_neg]
}
