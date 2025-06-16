resource "google_compute_managed_ssl_certificate" "frontend_certificate" {
  name = "frontend-ssl-certificate"

  managed {
    domains = ["test.beheerportaal.ctrllearning.nl"] # Frontend domein
  }
}

resource "google_compute_managed_ssl_certificate" "backend_certificate" {
  name = "backend-ssl-certificate"

  managed {
    domains = ["testapi.beheerportaal.ctrllearning.nl"] # Backend domein
  }
}

resource "google_compute_target_https_proxy" "frontend_https_proxy" {
  name             = "frontend-https-proxy"
  url_map          = google_compute_url_map.frontend_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.frontend_certificate.id]
}

resource "google_compute_target_https_proxy" "backend_https_proxy" {
  name             = "backend-https-proxy"
  url_map          = google_compute_url_map.backend_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.backend_certificate.id]
}

resource "google_compute_target_http_proxy" "frontend_http_proxy" {
  name    = "frontend-http-proxy"
  url_map = google_compute_url_map.frontend_url_map.id
}

resource "google_compute_target_http_proxy" "backend_http_proxy" {
  name    = "backend-http-proxy"
  url_map = google_compute_url_map.backend_url_map.id
}

resource "google_compute_url_map" "frontend_url_map" {
  name = "frontend-url-map"

  host_rule {
    hosts       = ["test.beheerportaal.ctrllearning.nl"]
    path_matcher = "frontend-matcher"
  }

  path_matcher {
    name = "frontend-matcher"
    default_service = google_compute_backend_service.frontend_cdn_backend.id
  }

  default_url_redirect {
    https_redirect = true
    strip_query    = false # Houd query-string intact bij de omleiding
  }

  depends_on = [
    google_compute_backend_service.frontend_cdn_backend
  ]
}

resource "google_compute_url_map" "backend_url_map" {
  name = "backend-url-map"

  host_rule {
    hosts       = ["testapi.beheerportaal.ctrllearning.nl"]
    path_matcher = "backend-api-matcher"
  }

  path_matcher {
    name = "backend-api-matcher"
    default_service = google_compute_backend_service.cloud_run_backend_service.self_link
  }

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }

  depends_on = [google_compute_backend_service.cloud_run_backend_service]
}

# Frontend HTTPS Forwarding Rule
resource "google_compute_global_forwarding_rule" "frontend_https" {
  name       = "frontend-https-rule"
  target     = google_compute_target_https_proxy.frontend_https_proxy.id
  port_range = "443"
}

# Frontend HTTP Forwarding Rule (redirect HTTP to HTTPS)
resource "google_compute_global_forwarding_rule" "frontend_http" {
  name       = "frontend-http-rule"
  target     = google_compute_target_http_proxy.frontend_http_proxy.id
  port_range = "80"
}

# Backend HTTPS Forwarding Rule
resource "google_compute_global_forwarding_rule" "backend_https" {
  name       = "backend-https-rule"
  target     = google_compute_target_https_proxy.backend_https_proxy.id
  port_range = "443"
}

# Backend HTTP Forwarding Rule (redirect HTTP to HTTPS)
resource "google_compute_global_forwarding_rule" "backend_http" {
  name       = "backend-http-rule"
  target     = google_compute_target_http_proxy.backend_http_proxy.id
  port_range = "80"
}

output "frontend_url" {
  value       = "https://test.beheerportaal.ctrllearning.nl"
  description = "De HTTPS URL van de frontend-service"
}

output "backend_url" {
  value       = "https://testapi.beheerportaal.ctrllearning.nl"
  description = "De HTTPS URL van de backend-service"
}