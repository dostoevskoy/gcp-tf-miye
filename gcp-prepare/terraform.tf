terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  backend "gcs" {
    bucket = "tf-state-miye"
    prefix = "terraform/prepare-infra"
  }
  required_version = ">= 0.13"
}

