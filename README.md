# Azure Network Security Ninja Training for WAF and Layer 7 Protection
## Important Note:  
The deployment templates used in this repository are modified from the original repository hosted at [WAF Attack Testing Lab](https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20WAF/Lab%20Template%20-%20WAF%20Attack%20Testing%20Lab).The intention is to simplify the template so as to not deploy all the components in the suggested architecture and keep the environment simple to carry out WAF tests and Sentinel Integration

## Deployed Components

| Resource                     | Purpose                                                                                                |
| ---------------------------- | ------------------------------------------------------------------------------------------------------ |
| Virtual Network-1            | VN1(Hub) has 2 Subnets 10.0.25.0/26 & 10.0.25.64/26 peered to VN1 and VN2 (DDoSProtection is disabled) |
| Virtual Network-2            | VN2(Spoke1) has 2 Subnets 10.0.27.0/26 & 10.0.27.64/26 peered to VN2                                   |
| Virtual Network-3            | VN3(Spoke2) has 2 Subnets 10.0.28.0/26 & 10.0.28.64/26 peered to VN1                                   |
| PublicIPAddress-1            | Static Public IP address for Application gateway                                                       |
| Virtual Machine-1            | Ubuntu 20.0.4 machines deployed in the Spoke 1 Network                                                 |
| Application Gateway v2 (WAF) | Pre-configured to publish webapp on HTTP on Public Interface                                           |
| Frontdoor                    | Pre-configured designer with Backend pool as Applicaion gateway public interface                       |
| WebApp(PaaS)                 | Pre-configured app for Frontdoor and Application Gateway WAF testing                                   |
| Diagnostics Settings         | Enabled for all the resources (publicIP, Application Gateway etc.,)                                    |

### Configuration of the Log Anlaytics Workspace
1. The template expects the Subscription Id of the pre-existing Log Analytics workspace. The workspace can be deployed from the ARM template or azure CLI commands. The resource deployment bash script has the following code to complete this step
```
# Log-analytics workspace is a prerequisite for the following deployment
# this can be included in the arm template as well
az monitor log-analytics workspace create -g $RG_SECOPS_NAME -n $DIAGNOSTICS_WORKSPACE_NAME
```
2. We will configure Azure Sentinel over this workspace to make use of the Microsoft developed Sentinel Workbooks, Additional Threat Hunting KQL Queries and the Playbooks for Threat & Vulnerability Mitigation
The procedure is available in this [article](https://docs.microsoft.com/en-us/azure/sentinel/quickstart-onboard)
**Note** :All the diagnostics logs from the resources that have the diagnostics settings enabled will now be available for the Sentinel queries

## Replacement of KALI with a basic Ubuntu Machine
The original template deploys a KALI Linux machine that can be used to perform Vulnerability Assessment and exploitation of Publicly exposed applications (in the context of this repository)

