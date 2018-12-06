<#

.DESCRIPTION
    Compile DSC configuration.

.NOTES
    Author: Neil Peterson
    Intent: Sample to demonstrate DSC compilation.
 #>

 $params = @{
    ConfigurationName = "windowsfeaturesupdated";
    ResourceGroupName = "HYB30";
    AutomationAccountName = "mikqh7uwvwxn4"
}

Start-AzAutomationDscCompilationJob @params