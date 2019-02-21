
<#
 .DESCRIPTION
    Creates and applies an Azure Policy to appends tag (costCenter) if it does not exsist.

    .NOTES
    Author: Neil Peterson
    Intent: Sample to demonstrate Azure Policy
 #>

param (
    [string]$ResourceGroupName,
    [string]$ResourceType,
    [string]$Location,
    [string]$PolicyName,
    [string]$PolicyFile="azuredeploy.json",
    [string]$PolicyParamFile="azurepolicy.parameters.json"
)

# Create  resource group
$ResourceGroupObject = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create policy
$PolicyDefinition = New-AzPolicyDefinition -Name $PolicyName -Policy $PolicyFile -DisplayName $PolicyName -Description $PolicyName -Parameter $PolicyParamFile -Mode All

# Assign policy
$PolicyParam = "{`"tagName`": {`"value`": `"costCenter`"},`"tagValue`": {`"value`": `"headquarter`"},`"resourceType`": {`"value`": `"$ResourceType`"}}"

New-AzPolicyAssignment -Name $PolicyName -DisplayName $PolicyName -Scope $ResourceGroupObject.ResourceId -PolicyDefinition $PolicyDefinition -PolicyParameter $PolicyParam