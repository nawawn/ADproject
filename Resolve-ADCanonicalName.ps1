﻿Function Resolve-ADUserCanonicalName
{
    [CmdletBinding()]    
    [OutputType([String])]
    Param( 
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [Alias("CName")]$CanonicalName 
    )
    Begin{}
    Process{
        return ((Get-ADUser -Filter 'Enabled -eq $true' -Properties CanonicalName).Where{$_.CanonicalName -eq $CanonicalName} | 
            Select-Object -ExpandProperty Name
        )
    }
    
<#
.Synopsis
   Resolve active directory canonicalname to a user name
.DESCRIPTION
   The cmdlet resolves the Active Directory CanonicalName to a user name. The canonical name can be passed via the pipeline. 
   This is useful to resolve ManagedBy user list from the MS Exchange Distribution Group.
.EXAMPLE
   Resolve-ADUserCanonicalName -CanonicalName "mydomain.com/UsersOU/Standard/Naw.Awn"
.EXAMPLE
   Get-DistributionGroup "Test-DG" | select -ExpandProperty ManagedBy | Resolve-ADUserCanonicalName
#>  
}