<#
 .DESCRIPTION
    Enables the IIS feature.

 .NOTES
    Author: Neil Peterson
    Intent: Configure Windows system for Ignote Tour LP4S3.
 #>

 configuration windowsfeatures {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    node localhost {

        WindowsFeature WebServer {
            Ensure = "Present"
            Name = "Web-Server"
        }
    }
}