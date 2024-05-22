# Defines project and service account data sources to use later on.
# Add any permissions or roles that are required here. Follow Least Privilege Principle.

data "google_project" "project" {
}

data "google_compute_default_service_account" "cloud_run_sa" {
}


# ----------------------- Client Service Account -----------------------

resource "google_service_account" "client_api_access" {
  account_id   = var.CLIENT_SERVICE_ACCOUNT
  display_name = "Client API access"
}

resource "google_project_iam_member" "api_invoker" {
  project = data.google_project.project.id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.client_api_access.email}"
}


# ----------------------- Developer Service Account -----------------------

resource "google_service_account" "developer_account" {
  account_id   = var.DEVELOPER_SERVICE_ACCOUNT
  display_name = "My Developer Account with Owner Role"
}

resource "google_project_iam_member" "owner_permissions" {
  project = data.google_project.project.id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.developer_account.email}"
}


# ----------------------- Cloud Build Service permissions for CI/CD integrations -----------------------
/* The cloud build service needs to be able to act as as other service accounts,
access cloud buckets, and develop/deploy cloud functions
*/
resource "google_project_iam_member" "cloud_build_service_account" {
  project = data.google_project.project.id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_run_admin" {
  project = data.google_project.project.id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_storage_object_admin" {
  project = data.google_project.project.id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_functions_developer" {
  project = data.google_project.project.id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# -------------------- Secret Manager permissions for cloud functions ----------------------

resource "google_project_iam_member" "secret_management" {
  project = data.google_project.project.id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${data.google_compute_default_service_account.cloud_run_sa.email}"
}



# ----------------------------------- OUTPUTS -------------------------------------------
output "client_service_account" {
  value = {
    account_id   = google_service_account.client_api_access.account_id
    email        = google_service_account.client_api_access.email
    name         = google_service_account.client_api_access.display_name
    download_key = "https://console.cloud.google.com/iam-admin/serviceaccounts/details/${google_service_account.client_api_access.unique_id}/keys?project=${data.google_project.project.project_id}"
  }
}

output "developer_service_account" {
  value = {
    account_id   = google_service_account.developer_account.account_id
    email        = google_service_account.developer_account.email
    name         = google_service_account.developer_account.display_name
    download_key = "https://console.cloud.google.com/iam-admin/serviceaccounts/details/${google_service_account.developer_account.unique_id}/keys?project=${data.google_project.project.project_id}"
  }
}
