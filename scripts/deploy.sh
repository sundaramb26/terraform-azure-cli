#!/usr/bin/env bash
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_SUBSCRIPTION_ID=
export ARM_TENANT_ID=
rm -rf AzureCloudLabInfrastructure/
git clone https://github.com/wongcyrus/AzureCloudLabInfrastructure
cp terraform.tfvars AzureCloudLabInfrastructure/
cd AzureCloudLabInfrastructure
terraform init
terraform apply -auto-approve
