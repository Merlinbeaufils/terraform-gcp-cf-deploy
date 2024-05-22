## REPO SETUP and DEPLOYMENT


### Prerequisites

* GCP Account: https://cloud.google.com
* gcloud CLI (GCP client) https://cloud.google.com/sdk/docs/install
* Terraform https://learn.hashicorp.com/tutorials/terraform/install-cli

### Setup GCP

1. Install beta component

```shell
gcloud components install beta
```

2. Init gcloud workspace

```shell
gcloud init
```

3. Set default authentication for command line

```shell
gcloud auth application-default login
```

5. Enable API's

```bash
gcloud services enable run.googleapis.com 
gcloud services enable compute.googleapis.com  
gcloud services enable firestore.googleapis.com  
gcloud services enable cloudbuild.googleapis.com  
gcloud services enable cloudfunctions.googleapis.com  
gcloud services enable cloudscheduler.googleapis.com  
gcloud services enable artifactregistry.googleapis.com  
gcloud services enable secretmanager.googleapis.com
```


6. Create Firestore database

```shell
gcloud firestore databases create --region=us-east4
```

7. Connect a github repository globally for CI/CD  https://console.cloud.google.com/cloud-build/triggers/connect
If working in a work environment, you may need to ask your admin to enable this feature.

## Deploy infrastructure
1. Setup virtual env

Mac/Linux
```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```
Windows
```bash
python -m venv venv
venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
```

2. Edit terraform deployment code to your specifications.

In terraform/02_variables.tf update all variables with [TODO FIRST].
Then update all other variables with [TODO] to match your needs as you go.

```shell
terraform init
```

3. Deploy your resources through terraform apply and voila!

```shell
terraform apply
```



You will get outputs for 2 service accounts and all cloud functions created.

```
cloud-functions = [
  {
    "name" = "FUNCTION_1_NAME"
    "uri" = "{url to use when sending requests}"
  },
  {
    ...
  },
]
client_service_account = {
  "account_id" = "client-api-invoker-account"
  "download_key" = {link to download key}
  "email" = {service account email}
  "name" = "Client API access"
}

developer_service_account = {
  "account_id" = "developer-service-account"
  "download_key" = {link to download key}
  "email" = {service account email}
  "name" = "My Developer Account with Owner Role"
}

```

If developing for a client, download and transmit the client service account key as well as the function uris to the client.
They will use these when making requests to the cloud functions.
You may keep the developer key for yourself to call and maintain the resources from your IDE or command line.

4. For CI/CD simply push the main branch, and the cloud build will be triggered automatically.


5. If this is just a demo, feel free to run terraform destroy to remove all resources.


```shell
terraform destroy
```
