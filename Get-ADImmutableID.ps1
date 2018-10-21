function Get-ADImmutableID{
    [CmdletBinding()]    
    [OutputType([String])]
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)][Alias("Id")][String]$Identity
    )
    Try {
        $ObjGuid = (Get-ADUser $Identity -Properties ObjectGUID).ObjectGUID
        $SysGuid = New-Object -TypeName System.Guid -ArgumentList $ObjGuid
        $ImmutableID = [Convert]::ToBase64String($SysGuid.ToByteArray())
        return $ImmutableID
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{ 
        Write-Output "The user doesn't exist!"
    }
}