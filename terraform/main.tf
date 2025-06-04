# Terraform provider definitie
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.35.0"
    }
  }
}

# Google Cloud Provider configuratie
provider "google" {
project     = var.project_id
region      = "europe-west1"
}