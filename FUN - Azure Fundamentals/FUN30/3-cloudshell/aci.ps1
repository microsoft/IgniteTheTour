# Create container
New-AzContainerGroup -ResourceGroup myACIDemo -Name mycontainerposh -Image microsoft/aci-helloworld -DnsNameLabel aci-demo-007-posh

# Get Public IP Address
Get-AzContainerGroup | where {$_.Name -eq 'mycontainerposh'} | Select IpAddress