
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

# Cloud CDN inzetten met Cloud Run Frontend
# Backend service voor Cloud CDN gebruiken
resource "google_compute_backend_service" "frontend_cdn_backend" {
  name     = "frontend-cdn-backend"
  protocol = "HTTP"
  timeout_sec = 30

  backend {
    group = google_cloud_run_service.cloud_run_frontend.id # Vermelding van frontend Cloud Run
  }

  enable_cdn = true # Schakel Cloud CDN in
  depends_on = [
    google_cloud_run_service.cloud_run_frontend,   # Frontend Cloud Run service must exist
  ]
}

# URL-map configureren voor Cloud CDN
resource "google_compute_url_map" "frontend_url_map" {
  name = "frontend-url-map"

  default_service = google_compute_backend_service.frontend_cdn_backend.id
  depends_on = [
    google_compute_backend_service.frontend_cdn_backend,  # Ensures that backend service exists
  ]
}

# HTTP Proxy voor de LoadBalancer
resource "google_compute_target_http_proxy" "frontend_http_proxy" {
  name    = "frontend-http-proxy"
  url_map = google_compute_url_map.frontend_url_map.id
  depends_on = [
    google_compute_url_map.frontend_url_map,  # Ensures URL map is created first
  ]
}

# Globale Forwarding rule om frontend URL openbaar beschikbaar te maken
resource "google_compute_global_forwarding_rule" "frontend_forwarding_rule" {
  name       = "frontend-forwarding-rule"
  target     = google_compute_target_http_proxy.frontend_http_proxy.id
  port_range = "80"
  depends_on = [
    google_compute_target_http_proxy.frontend_http_proxy,  # Needs HTTP proxy before creating this rule
  ]
}

# Voer de output van de frontend URL uit
output "frontend_url" {
  value       = google_compute_global_forwarding_rule.frontend_forwarding_rule.self_link
  description = "De URL van de frontend via Cloud CDN"
  depends_on = [
    google_compute_global_forwarding_rule.frontend_forwarding_rule,  # Ensure forwarding rule exists
  ]
}