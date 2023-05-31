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
![NetworkSecurityNinja](https://user-images.githubusercontent.com/13979783/185557892-e0054c41-c040-4111-97ff-d02a67edd2ea.png)

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
### Installation of xRDP and Security Tools in Ubuntu Machines
Reason for using an Ubuntu machine ->
1. The Parrot OS and Linux Machines were kind of expensive if used for longer periods of time (costed me ~ INR 27 per hour). If you are diligent about the use of the machines then you can use any of those offerings from the Marketplace. 
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
*Links to the lab steps*
1. Reconnaissance - https://techcommunity.microsoft.com/t5/azure-network-security-blog/part-2-reconnaissance-playbook-azure-waf-security-protection-and/ba-p/2030751
2. Vulnerability Exploitation Playbook (XSS) - https://techcommunity.microsoft.com/t5/azure-network-security-blog/part-3-vulnerability-exploitation-playbook-azure-waf-security/ba-p/2031047
3. Data Disclosure and Exfiltration Playbook (SQLi) - https://techcommunity.microsoft.com/t5/azure-network-security-blog/part-4-data-disclosure-and-exfiltration-playbook-azure-waf/ba-p/2031269

## Installation of the Log Analytics Workbook
Azure Monitor Workbook for WAF - https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20WAF/Workbook%20-%20WAF%20Monitor%20Workbook

## Understanding Anomaly Score based attack detection/prevention
**Excerpt from the lab-step#3 documentation**    
" Upon reviewing the Top 50 event trigger, filter by rule name we see all the rules which evaluated the POC XSS payload in the request; the Message, full details section shows that the traffic was blocked by Mandatory rule because the **Anomaly Score threshold was exceeded (Total Score: 53, XSS=35)** with XSS attack being the closest match"
Azure WAF has rules configured as a part of the default OWASP 3.x ruleset.Each of the Incoming web request is matched against these rules. If the request violates one or more of these rules then the firewall calculates the anomaly score of the request depending on the number of the rules violated and the cumulative value of the violations(each rule violation has a "severity" and an appropriate anomaly score mapped to it)  
The following links from the MS Documentation and a very good question on the github forum can help you make sense of the anomaly based detections and attack prevention
1. Anomaly score in the app gateway firewall and access logs  
https://github.com/MicrosoftDocs/azure-docs/issues/65894
2. Understanding WAF logs
https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/web-application-firewall-troubleshoot#understanding-waf-logs  
3. Anomaly Scoring Mode
https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview#anomaly-scoring-mode  

## Sentinel Integration
Integrating Azure WAF with Microsoft Sentinel i.e. configuring Azure Web Application Firewall (WAF) as a data source is an important step for us to capture all important **signals** , check for false positives, identify the patterns and possibly determine a mitigation plan based on the type of the attack detected.  
Data generated from the Application Gateway and/or the Azure Front Door logs are now available in the diagnotics table in the log analytics workspace.
*Configuration Reference*: https://techcommunity.microsoft.com/t5/azure-network-security-blog/integrating-azure-web-application-firewall-with-azure-sentinel/ba-p/1720306


### Sentinel KQL Queries
1. Identifying Unique IP Addresses that have sent beyond an acceptable number (user-defined threshold) of requests to the protected web application. This can then be either analyzed further to create a future attack prevention by adding the IP address to the blocked addresses list
2. Using the Indicators of Compromise (IOC) from Threat Intelligence data to enhance the threat hunting queries. Threat Intelligence data provides Threat indicators including URLs, file hashes, IP addresses, and other data with known threat activity like phishing, botnets, or malware 
   - For more detailed reading and walkthrough - [Threat Intelligence – TAXII and Threat Intelligence Platforms](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/data/sentinel-threat-intelligence)
3. Time series data analysis to determine IP anomaly. **Note**: This particular query uses the "Anomaly Scoring Mode" referenced in the previous section to identify the IP addresses that have exhibited anomolous behavior in a period of ~14 days
4. Requests identified as SQLi attacks by WAF based on the anomaly score and exporting *as Entities* the URL attacked and the client IP address that the attack originated from
   - [Path to the original query](https://github.com/Azure/Azure-Sentinel/blob/master/Detections/AzureWAF/AppGwWAF-SQLiDetection.yaml)
5. Requests identified as XSS attacks by WAF based on the anomaly score and exporting *as Entities* the URL attacked and the client IP address that the attack originated from
   - [Path to the original query](https://github.com/Azure/Azure-Sentinel/blob/master/Detections/AzureWAF/AppGwWAF-XSSDetection.yaml)

### Execution of the Sentinel Playbook for Mitigation
All of the queries documented in the previous section can be used to detect exploitations and attacks on a web application protected by WAF. In all these queries, the projections or the entities exported consist of the list of IP addresses from which the attack was triggered. Now that we know the source of the attacks, the suitable mitigation (or) repeated attack prevention would be adding the identitied IP addresses to the list of blocked IP addresses.  
Sentinel Block IP Playbook - https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20WAF/Playbook%20-%20WAF%20Sentinel%20Playbook%20Block%20IP  
**Note**: The playbook needs to be configured as the response action when a Sentinel Analytics rule based alert is triggered. This way the whole process can be automated 

## Mapping the Reconnaissance, XSS, SQLi and other assessment and exploitation techniques to the MITRE and Cyber Killchain frameworks

![image](https://user-images.githubusercontent.com/13979783/185143753-4a1e9bbc-b2d3-4426-858b-4d12c6a237bb.png)

## Azure Defender for Network  
IPFIX logs from Microsoft Routers, Analytics based on that, any possible mitigation that can be implemented through the Security Center  
https://www.youtube.com/watch?v=NpT7j0oH3-o&ab_channel=MicrosoftSecurity
	
## Scanning for Security Vulnerabilities, detection and Mitigation - Architecture Diagram
TBD 

## Cost-Saving Measures
- Delete and recreate Azure Bastion hosts on need basis
- Turn-off or deallocate the Attack Simulation Virtual Machine once the tests are executed and you are working on analyzing the data
- Delete the rg-netsecninja resource group at the end of the day. Use the deployResources.sh file to recreate the entire resource group whenever required. **Note**: It is better not to delete the rg-secops resource group as the Log Analytics Workspace and the security events captured would also be lost with it
- The Azure App-service hosting the attacked website can also be turned off when not used
 
## Futhering the Work
- Use of the tools available in *Metaspolit Framework* to perform more of the web-application attacks
- A very good training series recording from the INFOSEC TRAIN channel - [Web Application Testing | OWASP Top 10 | Cyber Security Training](https://www.youtube.com/watch?v=ZstyFyfS3g4&list=PLQL1JGGe-t0tfWbaGzQYdUfRRmc6-CSMz&index=6&t=12270s&ab_channel=INFOSECTRAIN)






