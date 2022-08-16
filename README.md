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

## Architecture Diagram

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
The original template deploys a KALI Linux machine that can be used to perform Vulnerability Assessment and exploitation of Publicly exposed applications (in the context of this repository). The Kali image has been removed from the Marketplace offerings. Also, enabling of xRDP on the KALI machine results in a permission issue and there seems to be no way around it.  
The other images available in the Marketplace are  
1. Parrot OS from Ntegral Inc
```
Image Reference to be used in the ARM Template
"publisher": "ntegralinc1586961136942",
"offer": "ntg_parrotos_linux",
"sku": "ntg_parrotos_linux_5",
"version": "latest"
```
2. Kali Linux from Ntegral Inc
```
Image Reference to be used in the ARM template
"publisher": "ntegralinc1586961136942",
"offer": "ntg_kali_linux",
"sku": "ntg_kali_linux_2022",
"version": "latest"
```
### Installation of xRDP and Security Tools in an Ubuntu Machines
Reason for using an Ubuntu machine ->
1. The Parrot OS and Linux Machines were kind of expensive if used for longer periods of time (costed me ~ INR 27 per hour). If you are diligent of the use of the machines then you can use any of those offerings from the Marketplace. The machines 
2. Both the machines come with the security testing and other related tools built into them and hence require a minimum of 2-4 vCPU and 16GB of RAM to be usable. These VM's base price are comparitively higher than the B2S machines that have been used in the base template. The hourly expenses can quickly escalate if not attended to

#### Basic Setup Information
1. Use an Ubuntu Image from the list of images available for the VMs available in Azure. The template uses the latest version of Ubuntu 20.04
   - The template uses a "Standard_D4s_v3" sized machines
2. Create a bastion host
   - This step is required to SSH into the machine and execute a bunch of commands to enable xRDP on the machine
   - Bastion seems to only support SSH for linux machines. Support for RDP through Bastion has been a requested feature but is not yet available
3. xRDP can be enabled for the machine using the instructions in this article
   - https://docs.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop?tabs=azure-cli
4. Once xRDP has been enabled, the bastion host can be deleted (for cost-saving purposes)
   - Create a public IP at the instance level and modify the NSG to allow SSH to this machine's public IP (**only from your client IP**) 
5. Set up the Ubuntu Machine for Vulnerability assessment and Exploitation
   - Installation of Open VAS on Ubuntu
     - https://www.techrepublic.com/article/how-to-install-the-openvas-vulnerability-scanner-on-ubuntu-16-04
   - Installation of other security tools on Ubuntu (Official forum)
     - https://help.ubuntu.com/community/InstallingSecurityTools
6. Once the necessary tools have been installed, the machine can be generalized and a managed image can be created from it
   - Capture the image of the machine after it has been generalized
	  - Save the managed image (Compute Image Gallery is another option)
	  - References: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource
	  - https://docs.microsoft.com/en-us/azure/virtual-machines/generalize
     - Creating a VM from the managed image (PowerShell) - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/create-vm-generalized-managed

## Execution of the Lab Steps

## Installation of the Log Analytics Workbook

## Sentinel Integration

### Sentinel KQL Queries

### Execution of the Sentinel Playbook for Mitigation

## Mapping the Reconnaissance, XSS, SQLi and other assessment and exploitation techniques to the MITRE and Cyber Killchain frameworks

### MITRE Charts

## Azure Defender for Network ( IPFIX logs from Microsoft Routers, Analytics based on that, any possible mitigation that can be implemented through Security Center)
	https://www.youtube.com/watch?v=NpT7j0oH3-o&ab_channel=MicrosoftSecurity
	
## Scanning for Security Vulnerabilities, detection and Mitigation - Architecture Diagram

## Cost-Saving Measures

## Futhering the Work







