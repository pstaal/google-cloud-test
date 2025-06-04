# Maak een publieke Bucket voor de website
resource "google_storage_bucket" "public_bucket" {
  name     = "frontend-rommel-bucket" # Unieke naam van de bucket
  location = "europe-west1"                   # Locatie van de bucket
  uniform_bucket_level_access = true # Aanbevolen: IAM op bucketniveau

  # Stel de website configuratie in
  website {
    main_page_suffix = "index.html" # Hoofdpagina / root bestand
    not_found_page   = "404.html"   # Foutpagina
  }

  # Opslagklasse (eventueel aanpassen)
  storage_class = "STANDARD"
}

# Geef publieke toegang tot alle objecten in de bucket
resource "google_storage_bucket_iam_member" "all_users_viewer" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers" # Iedereen krijgt alleen-lezen toegang
}