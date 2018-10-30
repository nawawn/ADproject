Function Get-ADGroupMembershipChanges {
    [CmdletBinding()]
    [Alias()]
    [OutputType([Object])]
    Param(
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true, 
            Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Identity")]$Name,
        [String]$Server
    )

    Try{
        $userobj = Get-ADUser -Identity $Name
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Warning "$Name can't be found!"
        return
    }
    return (
        Get-ADUser $Name -Properties MemberOf | Select -ExpandProperty memberOf |
         ForEach-Object {
            Get-ADReplicationAttributeMetadata $_ -Server $Server -ShowAllLinkedValues | 
              Where-Object {$_.AttributeName -eq 'member' -and $_.AttributeValue -eq $userobj.DistinguishedName} |
              Select-Object FirstOriginatingCreateTime, Object, AttributeValue
            } | Sort-Object FirstOriginatingCreateTime -Descending
    )
    <#
.Synopsis
   Get the history of AD Group membership changes
.DESCRIPTION
   The cmdlet gives you the details of the group membership changes and the date it was changed. This command can take the pipeline input from Get-ADuser cmdlet.
.EXAMPLE
   Get-ADGroupMembershipChanges -Name Username
.EXAMPLE
   With single AD user.
   Get-AdUser username | Get-ADGroupMembershipChanges
   With multiple AD user 
   Get-AdUser -Filter {enabled -eq $true} | %{Get-ADGroupMembershipChanges -Name $_}
#>
}