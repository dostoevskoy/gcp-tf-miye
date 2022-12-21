resource "random_integer" "salt" {
  min = 1000
  max = 9999
}

resource "google_project" "tf-project" {
  name            = "GCP-TF"
  project_id      = "gcp-tf-${random_integer.salt.result}"
  billing_account = data.google_billing_account.account.id
}

resource "google_project_service" "api" {
  for_each = toset([
    "cloudapis.googleapis.com", # Google Cloud APIs
    "compute.googleapis.com",   # Compute Engine API
    "iam.googleapis.com",       # Identity and Access Management (IAM) API
    "container.googleapis.com",  # GKE API
    "cloudresourcemanager.googleapis.com"
  ])
  project                    = google_project.tf-project.id
  service                    = each.value
  disable_dependent_services = true
}

resource "google_service_account" "sa" {
  account_id   = "gcp-tf-sa"
  display_name = "Service Account managed by Terraform"
  project      = replace(google_project.tf-project.id, "projects/", "")
}

resource "google_project_iam_member" "sa_iam" {
  for_each = toset(["roles/compute.networkAdmin", 
  "roles/compute.admin", 
  "roles/container.admin", 
  "roles/iam.serviceAccountUser", 
  "roles/iam.serviceAccountAdmin", 
  "roles/iam.roleAdmin", 
  "roles/resourcemanager.projectIamAdmin"])

  project = google_project.tf-project.id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"

  depends_on = [
    google_service_account.sa,
    google_project_service.api
  ]
}



