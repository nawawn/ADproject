Function Add-ADProxyAddress{
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)][ValidateNotNull()]
        [Alias("Id")][String]$Identity,
        [Alias("Dn")][String]$DomainName,
        [ValidateSet("smtp:","sip:","eum:")][String]$Protocol = "smtp:",
        [Switch]$Primary
    )

    If ($Primary){
        $proxyaddress = $Protocol.ToUpper() + $Identity + "@" + $DomainName
    }
    Else {
        $proxyaddress = $Protocol.ToLower() + $Identity + "@" + $DomainName
    }

    Try {
        $ProxyArray = Get-ADUser $Identity -Properties ProxyAddresses | Select -ExpandProperty ProxyAddresses
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Warning "$Identity - The user name can't be found!"
        return
    }

    If ($ProxyArray -contains $proxyaddress){
        Write-Output "$proxyaddress already exists."
        return        
    }
    Else { 
        Write-Verbose "Adding the $proxyaddress to AD ProxyAddress attribute..."
        Set-ADUser $Identity -Add @{Proxyaddresses=$proxyaddress}
    }

<#
.Synopsis
   Add the given proxyaddress to the AD attribute
.DESCRIPTION
   Add the new proxyaddress to an AD user account. The function is meant to be for batch tasks.
.PARAMETER Primary
   Use this switch if the value defined in the protocol is primary. By default, the protocol is secondary.
.EXAMPLE
   Add-ADProxyAddress -Identity UserName -DomainName "mysub.domain.com" -Protocol "smtp:"
.EXAMPLE
   Add-ADProxyAddress -Id UserName -Dn "mysub.domain.com" -Protocol "smtp:"
#>
}