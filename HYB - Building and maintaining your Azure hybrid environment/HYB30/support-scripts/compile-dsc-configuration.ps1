<#

.DESCRIPTION
    Compile DSC configuration.

.NOTES
    Author: Pierre Roman
    Intent: Sample to demonstrate DSC compilation.
 #>

 $params = @{
    ConfigurationName = "windowsfeaturesupdated";
    ResourceGroupName = "TWT-HYB";
    AutomationAccountName = "guar5vbmsjxb2"
}

Start-AzAutomationDscCompilationJob @params