# This file depends on your github repository being connected to your google triggers
locals {
  cr_env_map = {
    GCP_PROJECT = var.GCP_PROJECT
    FIRESTORE_ANALYTIC_USER_COLLECTION_ID="users"
  }
  cf_id = uuid()
  temp_dir = "temp"
}


# ------------------------ Cloud functions trigger ----------------------------

resource "google_cloudbuild_trigger" "cloud_functions_trigger" {
  name               = "${var.GCP_PROJECT}-cloud-functions-trigger"
  description        = "Package and deploy cloud functions when a push is made to the main or master branch"
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  tags               = ["zip", "upload", "deploy"]

  github {
    owner = var.GITHUB_REPOSITORY_OWNER
    name  = var.GITHUB_REPOSITORY_NAME

    push {
      branch = "^main|master$"
    }
  }

  depends_on = [
    google_project_iam_member.cloud_build_service_account,
    google_project_iam_member.cloud_build_storage_object_admin,
    google_project_iam_member.cloud_build_functions_developer
  ]

  build {
    step {
      name       = "python"
      id         = "zip cloud functions"
      args       = ["-c", "python cloud_functions/zip_cloud_functions.py --functions-dir ${var.CLOUD_FUNCTIONS_DIRECTORY} --app-dir ${var.APP_LOGIC_DIRECTORY} --output-dir ${var.ZIP_OUTPUT_DIRECTORY}" ]
      entrypoint = "bash"
    }


    dynamic "step" {
      for_each = toset(var.CLOUD_FUNCTIONS)
      content {
        name       = "gcr.io/cloud-builders/gsutil"
        id         = "Create Bucket Object ${step.key}"
        args       = ["cp", "${local.temp_dir}/${step.key}.zip", "gs://${google_storage_bucket.cloud_functions_bucket.name}/${step.key}.${sha256(local.cf_id)}.zip"]
      }
    }

    dynamic step {
      for_each = toset(var.CLOUD_FUNCTIONS)
      content {
        name = "gcr.io/google.com/cloudsdktool/cloud-sdk:latest"
        id   = "continuous deployment ${step.key}"
        args = [
          "gcloud",
          "functions",
          "deploy",
          replace(step.key, "_", "-"),
          "--source gs://${google_storage_bucket.cloud_functions_bucket.name}/${step.key}.${sha256(local.cf_id)}.zip",
          "--gen2",
          "--region ${var.REGION}",
        ]
      }
    }

    dynamic "step" {
      for_each = toset(var.CLOUD_FUNCTIONS)
      content {
        name       = "gcr.io/cloud-builders/gsutil"
        id         = "Remove bucket object ${step.key}"
        args       = ["rm", "gs://${google_storage_bucket.cloud_functions_bucket.name}/${step.key}.${sha256(local.cf_id)}.zip"]
      }
    }




    options {
      substitution_option = "ALLOW_LOOSE"
    }
  }
}

# ------------------------ Cloud functions deployment (manual) ----------------------------

# This will zip up the local files
resource "null_resource" "package_cloud_functions" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "python ${var.PREFIX}${var.CLOUD_FUNCTIONS_DIRECTORY}/zip_cloud_functions.py --prefix ${var.PREFIX} --functions-dir ${var.CLOUD_FUNCTIONS_DIRECTORY} --app-dir ${var.APP_LOGIC_DIRECTORY} --output-dir ${var.ZIP_OUTPUT_DIRECTORY}"
  }
}


resource "google_storage_bucket_object" "cloud_function_code" {
  for_each = toset(var.CLOUD_FUNCTIONS)
  provider = google-beta
  name     = "${each.key}.${sha256(local.cf_id)}.zip"
  bucket   = google_storage_bucket.cloud_functions_bucket.name
  source  = "${local.temp_dir}/${each.key}.zip"
  depends_on = [
    null_resource.package_cloud_functions,
    google_storage_bucket.cloud_functions_bucket
  ]
}


resource "google_cloudfunctions2_function" "cloud_functions" {
  for_each = toset(var.CLOUD_FUNCTIONS)
  provider = google-beta
  name     = replace(each.key, "_", "-")
  location = var.REGION

  build_config {
    runtime     = "python39"
    entry_point = "invoke"

    source {
      storage_source {
        bucket = google_storage_bucket.cloud_functions_bucket.name
        object = google_storage_bucket_object.cloud_function_code[each.key].name
      }
    }
  }

  service_config {
    max_instance_count    = 5
    available_memory      = "1G"
    timeout_seconds       = 60
    environment_variables = local.cr_env_map

    secret_environment_variables {
      key        = "OPENAI_API_KEY"
      project_id = var.GCP_PROJECT
      secret     = "OPENAI_API_KEY"
      version    = "latest"
    }

#     dynamic "secret_environment_variables" {
#       for_each = toset(var.SECRET_ENV_VARS)
#       content {
#         key        = each.key
#         project_id = var.GCP_PROJECT
#         secret     = each.key
#         version    = "latest"
#       }
#     }

  }

  depends_on = [
    google_project_iam_member.secret_management,
    google_storage_bucket_object.cloud_function_code,
  ]
}

resource "null_resource" "delete_temp_code" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -rf ${local.temp_dir}"
  }
  depends_on = [
    google_cloudfunctions2_function.cloud_functions
  ]
}

# ------------------------ Output links for accessing the cloud function apis ----------------------------

output "cloud-functions" {
  value = [
    for cf in google_cloudfunctions2_function.cloud_functions : {
      name : cf.name
      uri : cf.service_config[0].uri
    }
  ]
}
