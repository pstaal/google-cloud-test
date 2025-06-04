
# Step 1: Create a new custom VPC network
resource "google_compute_network" "rommelproject_vpc" {
  name                    = "rommelproject-vpc"
  auto_create_subnetworks = false # Disable auto subnet creation
  description             = "Custom VPC network for resources"
}

# Step 2: Create a subnet in "europe-west1" with the specified IP range
resource "google_compute_subnetwork" "rommelproject_subnet" {
  name          = "rommelproject-subnet"
  ip_cidr_range = var.subnet_ip_range
  region        = "europe-west1"
  network       = google_compute_network.rommelproject_vpc.id

  private_ip_google_access = true # Allows Google services to be accessed via private IP
}