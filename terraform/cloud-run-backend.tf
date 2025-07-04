
# serverless connector maken
resource "google_vpc_access_connector" "serverless_connector" {
  depends_on     = [null_resource.apis_enabled, google_compute_network.rommelproject_vpc]
  name           = "serverless-connector"
  region         = "europe-west1"  # Zorg dat de regio consistent is met andere resources
  network        = google_compute_network.rommelproject_vpc.self_link # Vervang dit door de juiste netwerknaam
  ip_cidr_range  = "10.11.0.0/28" # Niet overlappen met 10.10.0.0/16
  min_instances = 2        # Altijd 2 draaiende instanties
  max_instances = 10       # Schaal op naar maximaal 10 indien nodig
}

# firewall regels instellen
resource "google_compute_firewall" "allow_private_sql" {
  depends_on     = [null_resource.apis_enabled, google_compute_network.rommelproject_vpc]
  name    = "allow-private-sql"
  network = google_compute_network.rommelproject_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["5432"] # PostgreSQL poort
  }

  source_ranges = ["10.11.0.0/28"] # VPC Connector range
}

# Maak de Cloud Run service
resource "google_cloud_run_service" "cloud_run_backend" {
  name     = "cloud-run-backend-service"
  location = "europe-west1" # Zorg dat dit overeenkomt met de regio van je Cloud SQL-database en VPC

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  template {
    spec {
      containers {
        image = "europe-west1-docker.pkg.dev/rommelproject1/test-docker/backend-image"# Vervang met de juiste container image URL
        env {
          name  = "APP_HOST"
          value = "http://0.0.0.0" # Bindt aan een wildcard IP-adres
        }
        env {
          name = "TYPEORM_DATABASE"
          value = "${var.environment}_example_db"
        }
        env {
          name  = "APP_PORT"
          value = "8080" # Cloud Run vereist poort 8080
        }
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
        # Verbindt Cloud Run met de VPC Access Connector
        "run.googleapis.com/vpc-access-connector"       = google_vpc_access_connector.serverless_connector.name
        "run.googleapis.com/vpc-access-egress"         = "private-ranges-only" # Alleen private IP's
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_vpc_access_connector.serverless_connector,
    google_compute_firewall.allow_private_sql,
    google_secret_manager_secret_version.db_user_secret_version,
    google_secret_manager_secret_version.db_password_secret_version,
    google_service_account.cloud_run_sa,
    google_sql_database_instance.db_instance,
    google_project_iam_binding.artifact_registry_reader_role,
    google_project_iam_binding.storage_object_viewer_role,
  ]
}

resource "google_cloud_run_service_iam_member" "backend_public_access" {
  service  = google_cloud_run_service.cloud_run_backend.name
  location = google_cloud_run_service.cloud_run_backend.location

  role   = "roles/run.invoker" # Allow invocation rights for public users
  member = "allUsers" # Grant public access to all anonymous users
  depends_on = [google_cloud_run_service.cloud_run_backend]
}

# Serverless NEG voor Cloud Run Backend
resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name    = "cloud-run-neg"
  region  = google_cloud_run_service.cloud_run_backend.location
  network_endpoint_type = "SERVERLESS" # Geef aan dat dit een serverless NEG is

  cloud_run {
    service = google_cloud_run_service.cloud_run_backend.name # Verbindt met Cloud Run
  }

  depends_on = [google_cloud_run_service.cloud_run_backend]
}

resource "google_compute_backend_service" "cloud_run_backend_service" {
  name                  = "cloud-run-backend-service"
  protocol              = "HTTP"
  timeout_sec           = 30 # Verhoog indien nodig voor lange verzoeken
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id # Link met de NEG
  }

  depends_on = [google_compute_region_network_endpoint_group.cloud_run_neg]
}

