Function Get-AdDFSNamespace{    
    Param(    
        [Parameter()]
        [String]$Name
    )   
    Begin{
        $MyDomain   = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()            
        $DomainDN   = $MyDomain.GetDirectoryEntry() | Select-Object -ExpandProperty DistinguishedName
        $DfsConfig  = "CN=Dfs-Configuration,CN=System" 
        $SearchBase = $DfsConfig , $domainDN -Join ","
    }
    Process{
        If ($Name){
            Get-ADObject -Filter "Name -eq '$Name'" -SearchBase $SearchBase -Properties *
        }
        Else {
            Get-ADObject -Filter * -SearchBase $SearchBase -Properties *
        }        
    }
<#
.DESCRIPTION
    This cmdlet retrieves AD Domain Integrated DFS Namespace from Active Directory Dfs-Configuration
.EXAMPLE
   Get-AdDFSNamespace -Name 'PoC'
#>
}

Function Remove-AdDFSNamespace{
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(    
        [Parameter(Mandatory)]
        [String]$Name
    )   
    Begin{
        $MyDomain   = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()            
        $DomainDN   = $MyDomain.GetDirectoryEntry() | Select-Object -ExpandProperty DistinguishedName
        $DfsConfig  = "CN=Dfs-Configuration,CN=System" 
        $SearchBase = $DfsConfig , $domainDN -Join ","
    }
    Process{
        if ($PSCmdlet.ShouldProcess($Name, "Removing from $SearchBase")) {
            $ADObject = Get-ADObject -Filter "Name -eq '$Name'" -SearchBase $SearchBase
            If($ADObject){
                $ADObject | Remove-ADObject -Recursive -Confirm:$false
            }
            Else {
                Write-Warning "$Name can't be found under $SearchBase"
            }            
        }              
    }
<#
.DESCRIPTION
    This cmdlet removes orphanged AD Domain Integrated DFS Namespace from Active Directory Dfs-Configuration
.EXAMPLE
   Remove-AdDFSNamespace -Name 'PoC'
#>    
}
