Function Remove-ADProxyAddressByDomain{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)][ValidateNotNull()]
        [Alias("Identity")][String]$Name,
        [Alias("Dn")][String]$DomainName              
    )    
    
    Try {
        $AddrToRemove = (Get-ADUser $UserName -Properties ProxyAddresses).ProxyAddresses | Where-Object{$_ -like "*$DomainName"}
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Warning "$Name - The user name can't be found!"
        return
    }

    If ($AddrToRemove){
        Write-Verbose "Removing the $AddrToRemove from ADUser ProxyAddress attribute..."
        Set-ADUser $Name -Remove @{Proxyaddresses=$AddrToRemove}
    }
    Else { Write-Output "$Name has the proxy address with $DomainName already been removed." }

<#
.Synopsis
   Remove the given domain from AD User Proxyaddress attribute
.DESCRIPTION
   Remove the unwanted proxyaddress for a given domain name from AD user account.
.EXAMPLE
   Remove-ADProxyAddressByDomain -Name UserName -DomainName "mysub.domain.com"
.EXAMPLE
   Remove-ADProxyAddressByDomain -Identity UserName -Dn "mysub.domain.com" 
#>
}