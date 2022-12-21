provider "google" {
  project     = var.project_id
  credentials = file("../.creds/sa-private-key.json")
  region      = local.region
}
