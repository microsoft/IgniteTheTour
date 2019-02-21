<#

.DESCRIPTION
    Import DSC configuration.

.NOTES
    Author: Pierre Roman
    Intent: Sample to import DSC configuration.
 #>

$import = @{
    SourcePath = "windowsfeaturesupdated.ps1";
    ResourceGroupName = "TWT-HYB";
    AutomationAccountName = "guar5vbmsjxb2"
}

Import-AzAutomationDscConfiguration @import -Published