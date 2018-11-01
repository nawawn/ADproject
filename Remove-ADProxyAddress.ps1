Function Remove-ADProxyAddress{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)][ValidateNotNull()]
        [Alias("Id")][String]$Name,
        [Alias("Dn")][String]$DomainName,
        [ValidateSet("smtp:","SMTP:","sip:","SIP:","eum:","EUM:")]$Protocol = "smtp:"        
    )
        
    $proxyaddress = $Protocol + $Name + "@" + $DomainName
    Try {
        $ProxyArray = Get-ADUser $Name -Properties ProxyAddresses | Select -ExpandProperty ProxyAddresses
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Warning "$Name - The user name can't be found!"
        return
    }

    If ($ProxyArray -contains $proxyaddress){
        Write-Verbose "Removing the $proxyaddress from ProxyAddress attribute..."
        Set-ADUser $Name -Remove @{Proxyaddresses=$proxyaddress}
    }
    Else { Write-Output "$proxyaddress has already been removed." }

<#
.Synopsis
   Remove the given proxyaddress from the AD attribute
.DESCRIPTION
   Remove the unwanted proxyaddress from the given AD user account.
.EXAMPLE
   Remove-ADProxyAddress -Name UserName -DomainName "mysub.domain.com" -Protocol "smtp:"
.EXAMPLE
   Remove-ADProxyAddress -Id UserName -Dn "mysub.domain.com" -Protocol "smtp:"
#>
}