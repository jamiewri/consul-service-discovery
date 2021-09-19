#!/bin/bash


GCP_META_IPADDR_NIC0=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
GCP_META_HOSTNAME=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")


echo ${GCP_META_IPADDR_NIC0}
echo ${GCP_META_HOSTNAME}
