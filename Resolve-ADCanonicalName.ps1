function Resolve-ADCanonicalName
{
    [CmdletBinding()]    
    [OutputType([String])]
    Param( 
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)][Alias("CName")]$CanonicalName
    )
    return (Get-ADUser -Filter 'Enabled -eq $true' -Properties CanonicalName).Where{$_.CanonicalName -eq $CanonicalName} | Select -ExpandProperty Name    
}

#Resolve-CanonicalName -CName "adbm.britishmuseum.org/BM Users/Standard/ACottle"