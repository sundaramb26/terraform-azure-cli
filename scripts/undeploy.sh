#!/usr/bin/env bash
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_SUBSCRIPTION_ID=
export ARM_TENANT_ID=
cd AzureCloudLabInfrastructure
terraform destroy -auto-approve
