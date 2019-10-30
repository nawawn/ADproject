#Requires -Module ActiveDirectory

Function Resolve-ADEmployeeID{
    Param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ValueFromRemainingArguments,Position = 0)]      
        $EmployeeID
    )
    Begin{
        $Property = @('DistinguishedName','Name','DisplayName','EmployeeID','EmployeeNumber','UserPrincipalName')
    }
    Process{        
        Get-ADUser -Filter "EmployeeID -eq $EmployeeID" -Properties $Property | Select-Object $Property    
    }
<#
.DESCRIPTION
   Return the AD user for a given EmployeeID.
.EXAMPLE   
   Resolve-ADEmployeeID -EmployeeID 101
#>
}

Function Get-ADUserManager{
    Param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position = 0)]      
        [Alias('Identity')]
        $Name
    )
    Begin{
        $Hashtable = @{}
        $Property = @('DistinguishedName','Name','DisplayName','UserPrincipalName')
    }
    Process{
        Try {
            $UserInfo = Get-ADUser -Identity $Name -Properties Manager
        }
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            Write-Warning "The user doesn't exist!"
            Return
        }
        $Manager = $UserInfo.Manager
        If ($Manager){
            $ManagerInfo = Get-ADUser -Identity $Manager -Properties $Property | Select-Object $Property
            $Hashtable.Add('Manager',   $($ManagerInfo.Name))
            $Hashtable.Add('ManagerDN', $($ManagerInfo.DistinguishedName))
            $Hashtable.Add('ManagerUPN',$($ManagerInfo.UserPrincipalName))
            $Hashtable.Add('ManagerDisplayName',$($ManagerInfo.DisplayName))
        }
        Else{
            $Hashtable.Add('Manager',   '')
            $Hashtable.Add('ManagerDN', '')
            $Hashtable.Add('ManagerUPN','')
            $Hashtable.Add('ManagerDisplayName','')
        }        
        $Hashtable.Add('Name',$($UserInfo.Name))            
    }
    End{
        Return (New-Object PSObject -Property $Hashtable)
    }
<#
.DESCRIPTION
   Get the manager details for a given AD user.
.EXAMPLE   
   Get-ADUserManager -Identity 'UserName'
#> 
}

Function Test-ADUserManager{
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position = 0)]
        [Alias('Identity')]     
        $Name,
        [Parameter(ValueFromPipelineByPropertyName,ValueFromRemainingArguments,Position = 1)]      
        [AllowNull()][AllowEmptyString()]
        $Manager
    )    
    Process{        
        If($Manager){
            Try{
                $ManagerDN = (Get-ADUser -Identity $Name -Properties Manager).Manager
                $ADManager = Get-Aduser -Identity $Manager
            }
            Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
                Write-Warning "Invalid user or manager name!"
                Return
            }            
            If ($ManagerDN){
                Return ($ADManager -like (Get-Aduser -Identity $ManagerDN))
            }
            Else {
                Return $false
            }
        }
        Else{
            Return ($Null -ne ((Get-ADUser -Identity $Name -Properties Manager).Manager))
        }
    }
<#
.DESCRIPTION
   Test if the user has a manager or if the given manager is the current one
   Scenario (Without specifying the manager): Test-ADUserManager -Name 'UserName'
   TRUE: If the given user has a manager assigned
   FALSE: If the given user has no manager assigned
   Scenario: (With the manager username): Test-ADUserManager -Name 'UserName' -Manager 'ManagerName'
   TRUE: If the manager name matches
   FALSE: If the manager doesn't match
.EXAMPLE
   Test-ADUserManager -Name 'UserName'
   Test-ADUserManager -Identity 'UserName' -Manager 'ManagerName'  
.EXAMPLE
   Using the pipeline result from Get-ADUser cmdlet
   Get-ADUser -Identity 'UserName' | Test-ADUserManager
   Get-ADUser -Identity 'UserName' -Properties Manager | Test-ADUserManager   
#>    
}

Function Set-ADUserManager{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position = 0)]
        [ValidateNotNullOrEmpty()][Alias('Identity')]     
        $Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromRemainingArguments,Position = 1)]      
        [ValidateNotNullOrEmpty()]
        $Manager
    )
    Process{
        If ($PScmdlet.ShouldProcess("$Name", "Setting Manager attribute")){
            Set-ADUser -Identity $Name -Manager $Manager
        }
    }
<#
.DESCRIPTION
   Assgin a manager to an AD User
.EXAMPLE   
   Set-ADUserManager -Identity 'UserName' -Manager 'ManagerName'
.NOTES
   This will override the existing value 
#> 
}