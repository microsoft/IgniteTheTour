<#

.DESCRIPTION
    Import DSC configuration.

.NOTES
    Author: Neil Peterson
    Intent: Sample to import DSC configuration.
 #>

$import = @{
    SourcePath = "windowsfeaturesupdated.ps1";
    ResourceGroupName = "HYB30";
    AutomationAccountName = "mikqh7uwvwxn4"
}

Import-AzAutomationDscConfiguration @import -Published