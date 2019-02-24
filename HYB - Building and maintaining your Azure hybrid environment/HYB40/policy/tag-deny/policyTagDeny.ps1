
<#
 .DESCRIPTION
    Creates and applies an Azure Policy to deny creation if resource tag (costCenter) does not exsist.
 .NOTES
    Author: Neil Peterson
    Intent: Sample to demonstrate Azure Policy
 #>

param (
    [string]$ResourceGroupName,
    [string]$Location,
    [string]$PolicyName,
    [string]$PolicyFile="./policy/tag-deny/azuredeploy.json",
    [string]$PolicyParamFile="./policy/tag-deny/azurepolicy.parameters.json"
)

# Create  resource group
$ResourceGroupObject = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create policy
$PolicyDefinition = New-AzPolicyDefinition -Name $PolicyName -Policy $PolicyFile -DisplayName $PolicyName -Description $PolicyName -Parameter $PolicyParamFile -Mode All

# Assign policy
New-AzPolicyAssignment -Name $PolicyName -DisplayName $PolicyName -Scope $ResourceGroupObject.ResourceId -PolicyDefinition $PolicyDefinition -PolicyParameter '{"tagName": {"value": "costCenter"}}'