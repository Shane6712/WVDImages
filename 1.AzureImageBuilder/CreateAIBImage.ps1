##Create a VM image using Azure Image Builder that we will later store in Shared Image Gallery and deploy to a WVD Host Pool

#Set Variables - Resource Group to deploy into and the ARM template we use later
$RG = "vdi-aib-east-us-rg"
$TemplateUri = "https://raw.githubusercontent.com/Shane6712/WVDImages/master/1.AzureImageBuilder/DeployAnImage.json"

#Install AZ if not already installed and logged in
# Install-Module Az -Force
# Connect-AzAccount

#Start Image Deployment
#Build Image Template
New-AzResourceGroupDeployment -ResourceGroupName $RG -TemplateUri $TemplateUri -OutVariable Output -Verbose

#Check Name of Image Template. In the Azure portal select "Show hidden types" in the $RG RG
$Output.Outputs["imageTemplateName"].Value

#Build the Golden Image
$ImageTemplateName = $Output.Outputs["imageTemplateName"].Value
Invoke-AzResourceAction -ResourceGroupName $RG -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ResourceName $ImageTemplateName -Action Run

#Check Build Process - Will say "Building" for awhile (about 20 mins) and then "Distributing"(for about 2 mins). Once complete there will be an Image in the resource Group
(Get-AzResource -ResourceGroupName $RG -ResourceType Microsoft.VirtualMachineImages/imageTemplates -Name $ImageTemplateName).Properties.lastRunStatus
