
<#
 .DESCRIPTION
    Creates and applies an Azure Policy to deny creation if resource tag (costCenter) does not exsist.
 .NOTES
    Author: Neil Peterson
    Intent: Sample to demonstrate Azure Policy
 #>

 param (
    [string]$ResourceGroupNameFilter,
    [string]$PolicyName,
    [string]$PolicyFile="./policy/tag-deny/azuredeploy.json",
    [string]$PolicyParamFile="./policy/tag-deny/azurepolicy.parameters.json"
)

# Create policy
$PolicyDefinition = New-AzPolicyDefinition -Name $PolicyName -Policy $PolicyFile -DisplayName $PolicyName -Description $PolicyName -Parameter $PolicyParamFile -Mode All

# Get resource groups
$ResourceGroupObjects = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*$ResourceGroupNameFilter*"}

# Assign Policy
foreach ($ResourceGroup in $ResourceGroupObjects) {
    New-AzPolicyAssignment -Name $PolicyName -DisplayName $PolicyName -Scope $ResourceGroup.ResourceId -PolicyDefinition $PolicyDefinition -PolicyParameter '{"tagName": {"value": "costCenter"}}'
}