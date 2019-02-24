<#
 .DESCRIPTION
    Assign Azure BluePrint
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
   [string]$SubscriptionId
)

# Acquire an access token
$Resource = 'https://management.core.windows.net/'
$RequestAccessTokenUri = 'https://login.microsoftonline.com/{0}/oauth2/token' -f $TenantId
$body = 'grant_type=client_credentials&client_id={0}&client_secret={1}&resource={2}' -f $ClientId, $ClientSecret, $Resource
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

# Assign BluePrint
$Headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")
$body = Get-Content -Raw -Path $Blueprint | ConvertFrom-Json
$body.properties.blueprintId = '/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Blueprint/blueprints/{1}' -f $ManagementGroup, $BlueprintName
$BPAssign = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.Blueprint/blueprintAssignments/{1}?api-version=2017-11-11-preview' -f $SubscriptionId, $BlueprintName
$body = $body  | ConvertTO-JSON -Depth 4
write-output $body
Invoke-RestMethod -Method PUT -Uri $BPAssign -Headers $Headers -Body $body -ContentType "application/json"