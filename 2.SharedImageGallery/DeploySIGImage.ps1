#Create a Shared Image Gallery and put an Azure Image Builder into it to them deploy via WVD.

#Setup some variables: $ResourceGroupName is for the Shared Image Gallery, $AIBRG is the RG that already exists and has your AIB Image in it and $HPRG is the WVD host pool RG
$ResourceGroupName = "vdi-sig-east-us-rg"
$AIBRG = "vdi-aib-east-us-rg"
$HPRG = "wvd-sig-hp-rg"
$SIG = "WVDSharedImageGallery"
$Def = "wvd-image-definition1"
$Location = "eastus"
$SubscriptionID = "428a21e5-ca47-401c-bb65-24687c8943b1"
$AppID = "cf32a0cc-373c-47c9-9156-0db11f6a6dfc"
$Role = "Contributor"


#Either use this for Local template
#$TemplateFile = "Path To\DeployAHostPoolFromaSIGImage.json"
#$TemplateParameterFile = "Path To\DeployAHostPoolFromASIGImage.parameters.json"
#Or from Github
$TemplateURI = "https://raw.githubusercontent.com/Shane6712/WVDImages/master/2.SharedImageGallery/DeployAHostPoolFromASIGImage.json"
$TemplateParameterURI = "https://raw.githubusercontent.com/Shane6712/WVDImages/master/2.SharedImageGallery/DeployAHostPoolFromASIGImage.parameters.json"

#Install Module if you don't have it yet
# Install-Module Az -Force

#Login to Azure RM if you havent already
# Add-AzAccount

#Create New ResourceGroup if not already existing
New-AzResourceGroup -Name $resourceGroupName -Location $Location
#Create Shared Image Gallery
New-AzGallery -ResourceGroupName $ResourceGroupName -name $SIG -Location $Location -Description "Shared Image Gallery for WVD Deployments"
#Create an Image Definition
New-AzgalleryImageDefinition -Name $Def -GalleryName $SIG -ResourceGroupName $ResourceGroupName -Location $Location -OsState generalized -OsType Windows -Publisher 'myPublisher' -Offer 'myOffer' -Sku 'mySKU'

#Assign Azure Image Builder rights to the SIG
New-AzRoleAssignment -RoleDefinitionName $Role -ApplicationId $AppID -ResourceGroupName $ResourceGroupName

##Distribute section. 
#Distribute the Image metadata to Shared Image Gallery via Github
$DistributeTemplateUri = "https://raw.githubusercontent.com/Shane6712/WVDImages/master/2.SharedImageGallery/DistributeAnImageToSIG.json"

#Image Definition
$ImageDefinitionId = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/galleries/$SIG/images/$Def"
                    
New-AzResourceGroupDeployment -ResourceGroupName $AIBRG -TemplateUri $DistributeTemplateUri -OutVariable Output -Verbose -SIGImageDefinitionId $ImageDefinitionId
#Or
# New-AzResourceGroupDeployment -ResourceGroupName $AIBRG -TemplateFile $DistributeTemplatefile -OutVariable Output -Verbose -SIGImageDefinitionId $ImageDefinitionId

#Start Image Build
$ImageTemplateName = $Output.Outputs["imageTemplateName"].Value
Invoke-AzResourceAction -ResourceGroupName $AIBRG -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ResourceName $ImageTemplateName -Action Run

#Check the status of the build
(Get-AzResource -ResourceGroupName $AIBRG -ResourceType Microsoft.VirtualMachineImages/imageTemplates -Name $ImageTemplateName).Properties.lastRunStatus

##WVD Host pool section
#Start the WVD host pool deployment
New-AzResourceGroup -Name $HPRG -Location $Location
#Create Shared Image Gallery
#Either Local
# New-AzResourceGroupDeployment -ResourceGroupName $hprg -TemplateFile $TemplateFile -TemplateParameterFile $TemplateParameterFile -Verbose
#OR Github
New-AzResourceGroupDeployment -ResourceGroupName $hprg -TemplateURI $TemplateURI -TemplateParameterUri $TemplateParameterURI -Verbose

