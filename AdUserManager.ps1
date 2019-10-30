Function Resolve-ADEmployeeID{
    Param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ValueFromRemainingArguments,Position = 0)]      
        $EmployeeID
    )
    Process{
        $Property = @('DistinguishedName','Name','DisplayName','EmployeeID','EmployeeNumber','UserPrincipalName')
        Get-ADUser -Filter "EmployeeID -eq $EmployeeID" -Properties $Property | Select-Object $Property    
    }
}

Function Get-ADUserManager{
    Param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position = 0)]      
        [Alias('Identity')]
        $Name
    )
    Begin{
        $Hashtable = @{}
    }
    Process{
        $Property = @('DistinguishedName','Name','DisplayName','UserPrincipalName')
        
        $Manager = (Get-ADUser -Identity $Name -Properties Manager).Manager
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
        $UserInfo = Get-ADUser -Identity $Name -Properties $Property | Select-Object $Property        
        $Hashtable.Add('Name',$($UserInfo.Name))            
    }
    End{
        Return (New-Object PSObject -Property $Hashtable)
    }
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
            $MgrDN = (Get-ADUser -Identity $Name -Properties Manager).Manager
            If ($MgrDN){
                Return ((Get-Aduser -Identity $Manager) -like (Get-Aduser -Identity $MgrDN))
            }
            Else {
                Return $false
            }
        }
        Else{
            Return ($Null -ne ((Get-ADUser -Identity $Name -Properties Manager).Manager))
        }
    }    
}

Function Set-ADUserManager{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position = 0)]
        [ValidateNotNullOrEmpty()][Alias('UserName')]     
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
}