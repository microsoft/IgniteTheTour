<#
 .DESCRIPTION
    Catches VM alert, and posts to MS Teams.

 .NOTES
    Author: Neil Peterson
    Intent: Sample to demonstrate Azure Automation Features.
 #>

 Param(
    [parameter (Mandatory=$false)]
    [object] $WebhookData
)

# Parse Data
$RequestBody = $WebhookData.RequestBody | ConvertFrom-Json
$VMName = $RequestBody.data.SearchResult.tables.rows

# Get Automation Assets
$TeamsURI = Get-AutomationVariable -Name 'TeamsURI'
$TenantID = Get-AutomationVariable -Name 'TenantID'
$Creds = Get-AutomationPSCredential -Name 'AzureRM'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'

# Login Azure
Login-AzureRMAccount -ServicePrincipal -Credential $Creds -TenantId $TenantID

# Teams request body
$Body = ConvertTo-Json @{
    text = 'IIS Service has stopped: ' + $VMName
}

# Teams request
Invoke-WebRequest -Uri $TeamsURI -Method Post -Body $Body -ContentType 'application/json' -UseBasicParsing

# Get Azure VM
$VMObject = Get-AzureRmVM | where {$_.Name -eq $VMName}

# Run script to start service
$params = @{
    Name = "startIIS";
    ResourceGroupName = $ResourceGroupName;
    Location = $Location
    VM = $VMObject.Name;
    FileUri = "https://raw.githubusercontent.com/neilpeterson/azure-automation-dsc/master/support-scripts/w3svc-service.ps1";
    Run = "w3svc-service.ps1"
}

Set-AzureRmVMCustomScriptExtension @params