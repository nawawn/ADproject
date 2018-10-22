﻿Function Remove-ADProxyAddress{
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)][ValidateNotNull()]
        [Alias("Id")][String]$Identity,
        [Alias("Dn")][String]$DomainName,
        [String]$Protocol = "smtp:"
    )    
    $proxyaddress = $Protocol.ToLower() + $Identity + "@" + $DomainName
    Try {
        $ProxyArray = Get-ADUser $Identity -Properties ProxyAddresses | Select -ExpandProperty ProxyAddresses
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Output "The user doesn't exist!"
        return
    }

    If ($ProxyArray -contains $proxyaddress){
        Write-Verbose "Removing the $proxyaddress from ProxyAddress attribute..."
        Set-ADUser $Identity -Remove @{Proxyaddresses=$proxyaddress}        
    }
    Else { Write-Warning "$proxyaddress has already been removed." }

<#
.Synopsis
   Remove the given proxyaddress from the AD attribute
.DESCRIPTION
   Remove the unwanted proxyaddress from the given AD user account.
.EXAMPLE
   Remove-ADProxyAddress -Identity UserName -DomainName "mysub.domain.com" -Protocol "smtp:"
.EXAMPLE
   Remove-ADProxyAddress -Id UserName -Dn "mysub.domain.com" -Protocol "smtp:"
#>
}