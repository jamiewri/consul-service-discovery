#!/bin/bash

# Use the GCE Servie account to configure the default application credentials for the gcloud cli.
gcloud init --skip-diagnostics \
  --account bastion@devopstower.iam.gserviceaccount.com \
  --project devopstower

# Set some defaults for the gcloud cli
gcloud config set project devopstower
gcloud config set compute/zone australia-southeast1-a

# Use the gcloud cli to generate out kubeconfig for cluster-1
gcloud container clusters get-credentials  --zone australia-southeast1-a --project devopstower cluster-1

# At this point we should have vault, consult and kubectl clis all correctly configured

# Install the Vault injector w/ external vault into the default namespace
helm repo add hashicorp https://helm.releases.hashicorp.com

helm install vault \
  --set="injector.enabled=true" \
  --set="injector.externalVaultAddr=http://vault.internal-gcp.openinfra.io:8200"


# Create demo data
vault kv put secrets/web-app/jamie secret=password

# Create poicy that allows read only to demo data
vault policy write web-app - << EOF
path "secrets/web-app/*" {
  capabilities = ["read"]
}
EOF

# Configure the kubernetes auth provider to trust the web-app serviceAccount from the default namespace
vault write auth/kubernetes/role/web-app-role \
   bound_service_account_names=web-app \
   bound_service_account_namespaces=default \
   policies=web-app \
   ttl=15m
