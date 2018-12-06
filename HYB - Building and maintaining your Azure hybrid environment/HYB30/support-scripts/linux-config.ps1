<#
 .DESCRIPTION
    Installs the Nano package

 .NOTES
    Author: Neil Peterson
    Intent: Configure Linux system for Ignite Tour LP4S3.
 #>

 configuration linuxpackage {

    Import-DSCResource -Module nx

    Node "localhost" {

        nxPackage nginx {
            Name = "nginx"
            Ensure = "Present"
        }
    }
}