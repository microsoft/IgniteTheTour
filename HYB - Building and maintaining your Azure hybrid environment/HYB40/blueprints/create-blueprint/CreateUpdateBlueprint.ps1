<#
 .DESCRIPTION
    Creates Azure BluePrint

 .NOTES
    Author: Neil Peterson
    Intent: Sample to demonstrate Azure BluePrints with Azure DevOps
 #>

 param (
    [string]$ManagementGroup,
    [string]$BlueprintName,
    [string]$Blueprint,
    [string]$TenantId,
    [string]$ClientId,
    [string]$ClientSecret,
    [string]$SubscriptionId,
    [string]$Artifacts
  )

# Acquire an access token
$Resource = "https://management.core.windows.net/"
$RequestAccessTokenUri = 'https://login.microsoftonline.com/{0}/oauth2/token' -f $TenantId
$body = "grant_type=client_credentials&client_id={0}&client_secret={1}&resource={2}" -f $ClientId, $ClientSecret, $Resource
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

#  # Create BluePrint
$Headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")
$BPCreateUpdate = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}?api-version=2017-11-11-preview' -f $ManagementGroup, $BlueprintName
$body = Get-Content -Raw -Path $Blueprint
Invoke-RestMethod -Method PUT -Uri $BPCreateUpdate -Headers $Headers -Body $body -ContentType "application/json"

# Get Published BP / Last version number
$Get = "https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}/versions?api-version=2017-11-11-preview" -f $ManagementGroup, $BlueprintName
$pubBP = Invoke-RestMethod -Method GET -Uri $Get -Headers $Headers

# If not exsist, version = 1, else version + 1
if (!$pubBP.value[$pubBP.value.Count - 1].name) {
   $version = 1
} else {
   $version = ([int]$pubBP.value[$pubBP.value.Count - 1].name) + 1
}

$allArtifacts = Get-ChildItem $Artifacts

write-host $artifacts

foreach ($item in $allArtifacts) {
   $body = Get-Content -Raw -Path $item
   $artifactURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}/artifacts/{2}?api-version=2017-11-11-preview" -f $ManagementGroup, $BlueprintName, $item.name.Split('.')[0]
   Invoke-RestMethod -Method PUT -Uri $artifactURI -Headers $Headers -Body $body -ContentType "application/json"
}

# Publish Blueprint
$Publish = "https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}/versions/{2}?api-version=2017-11-11-preview" -f $ManagementGroup, $BlueprintName, $version
Invoke-RestMethod -Method PUT -Uri $Publish -Headers $Headers