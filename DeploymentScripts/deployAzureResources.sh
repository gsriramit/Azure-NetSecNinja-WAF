#!/bin/bash

#install JQ to be able to edit the ARM params values from script
# apt install jq

# Declare the variables
RG_LOCATION='eastus2'
RG_NETWORK_NAME='rg-netsecninja'
RG_SECOPS_NAME='rg-secops'
SUBSCRIPTION_ID=""
TENANT_ID=""
DEPLOYMENT_NAME="NetSecNinja-WAFTesting"
DIAGNOSTICS_WORKSPACE_NAME="la-sentinel-workspace"

# Login to the account and set the target subscription
az login
az account set -s "${SUBSCRIPTION_ID}"

# Create the resource groups. In an enterprise setup, the resources would be split differently.
az group create -n $RG_NETWORK_NAME -l $RG_LOCATION
az group create -n $RG_SECOPS_NAME -l $RG_LOCATION

# Log-analytics workspace is a prerequisite for the following deployment
# this can be included in the arm template as well
az monitor log-analytics workspace create -g $RG_SECOPS_NAME -n $DIAGNOSTICS_WORKSPACE_NAME

#Onboard the workspace to sentinel. This way the DDOS, WAF and Azure Firewall Logs can be examined
# using Sentinel rules. SOAR can be done through the playbooks (available out of the box)

# Microsoft Sentinel pricing details
# https://azure.microsoft.com/en-us/pricing/details/microsoft-sentinel/

# Image usage terms need to be accpeted before the KALI Linux image can be used
az vm image accept-terms --offer 'kali-linux' --publisher 'kali-linux' --plan 'kali'
# This command has been deprecated and will be removed in version '3.0.0'. Use 'az vm image terms accept' instead.
az vm image terms accept --offer 'ntg_kali_linux' --publisher 'ntegralinc1586961136942' --plan 'ntg_kali_linux_2022'

# This deployment shd create the hub virtual network and the application gateway 
az deployment group create -g $RG_NETWORK_NAME -n $DEPLOYMENT_NAME -f DeploymentTemplates/AzNetSecdeploy_Juice-Shop_Modified.json -p DeploymentTemplates/AzNetSecdeploy_Juice-Shop.parameters.json

# query the required outputs from each of the deployments
# az deployment group show -g $RG_NETWORK_NAME -n $DEPLOYMENT_NAME --query "properties.outputs" -o json > hubdeployment-outputs.json

