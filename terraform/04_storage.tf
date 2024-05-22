
locals {

  firestore_fields = {
    deleted : {
      booleanValue : true
    }
  }
}

resource "random_string" "random_id" {
  length  = 8
  special = false
}

# ----------------------- Firestore Collections -----------------------
resource "google_firestore_document" "firestore_collections" {
  for_each    = toset(var.FIRESTORE_COLLECTIONS)
  collection  = each.key
  document_id = random_string.random_id.result
  fields      = jsonencode(local.firestore_fields)
}


# ----------------------- Storage Buckets -----------------------
resource "google_storage_bucket" "cloud_functions_bucket" {
    name                        = "${var.CLOUD_FUNCTIONS_BUCKET}-${lower(random_string.random_id.result)}"
    location                    = var.REGION
    force_destroy               = true
    uniform_bucket_level_access = true
}

data "google_storage_bucket" "existing_buckets" {
  for_each = toset(var.EXISTING_BUCKETS)
  name     = each.key
}
