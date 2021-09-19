#!/bin/bash

gcloud projects add-iam-policy-binding "devopstower" \
  --member='serviceAccount:bastion@devopstower.iam.gserviceaccount.com' \
  --role='roles/compute.viewer'


gcloud projects add-iam-policy-binding "devopstower" \
  --member='serviceAccount:bastion@devopstower.iam.gserviceaccount.com' \
  --role='roles/container.developer'

gcloud projects add-iam-policy-binding "devopstower" \
  --member='serviceAccount:bastion@devopstower.iam.gserviceaccount.com' \
  --role='roles/container.clusterAdmin'
