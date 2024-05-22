/*
This defines the providers you will need.
AWS, Azure, Google, Docker etc.
In this case we only use google gcp resources.
We also need to use the google-beta provider because Gen-2 cloud functions are considered beta.
*/

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.64.0"
    }
  }
}

provider "google" {
  project = var.GCP_PROJECT
  region  = var.REGION
}

provider "google-beta" {
  project     = var.GCP_PROJECT
  region      = var.REGION
}
