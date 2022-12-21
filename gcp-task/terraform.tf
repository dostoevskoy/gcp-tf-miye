terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-miye"
    prefix = "terraform/gcp-task"
  }
  required_version = ">= 0.13"
}
