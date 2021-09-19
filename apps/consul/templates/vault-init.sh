#! /usr/bin/env bash
set -xe
set -o pipefail

GCP_META_IPADDR_NIC0=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
GCP_META_HOSTNAME=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")


echo ${GCP_META_IPADDR_NIC0}
echo ${GCP_META_HOSTNAME}


# Generate Vault config file
cat << EOF > /etc/vault.hcl
listener "tcp" {
	address     = "${GCP_META_IPADDR_NIC0}:8200"
	tls_disable = 1
}

listener "tcp" {
	address     = "127.0.0.1:8200"
	tls_disable = 1
}

api_addr = "http://${GCP_META_IPADDR_NIC0}:8200"
cluster_addr = "http://${GCP_META_IPADDR_NIC0}:8201"

ui = true

storage "consul" {
  address = "${google_compute_address.consul.address}:8500"
  path    = "vault-${random_id.instance_id.hex}"
}


seal "gcpckms" {
  project     = "${var.project}"
  region      = "${var.keyring_location}"
  key_ring    = "${var.key_ring}-${random_id.instance_id.hex}"
  crypto_key  = "${var.crypto_key}"
}

disable_mlock = true
EOF

sleep 15
sudo systemctl restart vault >> /home/packer/vault-systemctl.log 2>&1
source /etc/profile.d/vault.sh
sleep 15
time vault operator init -key-shares=5 -key-threshold=3 -format json >> /home/packer/vault-unseal.log 2>&1
echo -n ${file(var.vault_license_path)} >> /home/packer/vault-license.hclic 2>&1
vault login `cat /home/packer/vault-unseal.log  | jq .root_token -r`  >> /home/packer/vault-login.log 2>&1
vault kv put /sys/license text=`cat /home/packer/vault-license.hclic` >> /home/packer/vault-license-apply.log 2>&1
vault auth enable gcp >> /home/packer/vault-auth.log 2>&1
vault write auth/gcp/role/my-iam-role \
  type="iam" \
  policies="dev" \
  bound_service_accounts="vault-server@devopstower.iam.gserviceaccount.com"
vault secrets enable -path=secrets/ kv  >> /home/packer/vault-data.log 2>&1
vault kv put secrets/myapp/config   ttl="30s"   apikey='MYAPIKEYHERE'  >> /home/packer/vault-data.log 2>&1
vault kv get secrets/myapp/config  >> /home/packer/vault-data.log 2>&1
vault auth enable kubernetes  >> /home/packer/vault-auth.log 2>&1
vault secrets enable -path=pki/ pki  >> /home/packer/vault-data.log 2>&1
touch /home/packer/metadata-done
