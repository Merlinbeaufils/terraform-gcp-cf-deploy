/*
This file defines all the relevant variables.
This will be where the bulk of the changes between projects will be
*/


# ----------------- PROJECT CONFIGURATION -----------------
variable "GCP_PROJECT" {
  type        = string
  description = "GCP project id"
  default     = "terraform-demo-project-424017" # TODO FIRST: change to your project id
}

variable "GITHUB_REPOSITORY_NAME" {
  type        = string
  description = "Github repository name"
  default     = "terraform-gcp-cf-deploy" # TODO FIRST: change to your github repo name
}

variable "GITHUB_REPOSITORY_OWNER" {
  type        = string
  description = "Username of the github repository owner"
  default     = "Merlinbeaufils" # TODO FIRST: change to your github repo owner
}

variable CLOUD_FUNCTIONS_BUCKET {
  type        = string
  description = "Bucket name for storing and deploying cloud functions"
  default     = "cloud-functions"
}

variable "REGION" {
  type        = string
  description = "GCP region"
  default     = "us-east4"
}

# ----------------- Project Directory Specifications -----------------

variable "PREFIX" {
    type        = string
    description = "Backwards path from terraform folder to root of directory"
    default     = "../" # TODO: change to your prefix
}

variable "APP_LOGIC_DIRECTORY" {
  type        = string
  description = "Path to the application logic from the root of your repository"
  default     = "app" # TODO: change to your prefix
}

variable "CLOUD_FUNCTIONS_DIRECTORY" {
  type        = string
  description = "Path to the cloud functions from the root of your repository"
  default     = "cloud_functions" # TODO: change to your prefix
}

variable "ZIP_OUTPUT_DIRECTORY" {
  type        = string
  description = "Where to store the temporary zips for cloud functions"
  default     = "terraform/temp" # TODO: change to your prefix
}



# ----------------- SERVICE ACCOUNTS FOR ACCESSING RESOURCES -----------------

variable "CLIENT_SERVICE_ACCOUNT" {
  type        = string
  description = "Client account for calling Cloud Functions/Cloud Run endpoints"
  default     = "client-api-invoker-account"
}

variable "DEVELOPER_SERVICE_ACCOUNT" {
  type        = string
  description = "Service account for developer. Typically given 'Owner role' for the project"
  default     = "developer-service-account" # DO NOT SHARE WITH ANYONE!
}


# ----------------- STORAGE -----------------

variable "FIRESTORE_COLLECTIONS" {
  description = "List of Firestore collection names to be created"
  type        = list(string)
  default     = ["users"] # TODO: add all relevant firestore collections
}

variable "EXISTING_BUCKETS" {
  description = "List of existing buckets that we wont handle with terraform to avoid deleting important data"
  type        = list(string)
  default     = [] # TODO: add all relevant existing buckets
}

# ----------------- CLOUD FUNCTIONS SPECIFIC -----------------

variable "CLOUD_FUNCTIONS" {
  type        = list(string)
  description = "Name of the cloud functions"
  default     = ["simple_function", "user_remove", "user_update", "user_set"] # TODO: add all relevant cloud functions
}

/*variable "ENVIRONMENT_VARIABLES" {
  type        = map(string)
  description = "Environment variables for your cloud functions"
  default = {
    "PROJECT_ID" = "terraform-demo-project-424017",
    "REGION"     = "us-east4",
    "BUCKET"     = "cloud-functions"
  } # TODO: add any relevant environment variables for your cloud functions. Ensentially this is your .env file.
}*/

# variable "SECRET_ENV_VARS" {
#   type        = list(string)
#   description = "Secrets to retrieve from gcp secret manager for your cloud functions"
#   default     = ["OPENAI_API_KEY", "SECRET_FORMULA"]
#   # TODO: add all your relevant secrets for your cloud functions. (For simplicity, name them in secret manager as you want them to show up as environment variables)
# }
