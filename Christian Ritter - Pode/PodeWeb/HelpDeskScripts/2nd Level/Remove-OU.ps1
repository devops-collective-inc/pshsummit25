<#
.SYNOPSIS
Removes an Organizational Unit (OU) from Active Directory.

.DESCRIPTION
Removes an Organizational Unit (OU) from Active Directory. The script generates a custom object indicating the success or failure of the OU removal process.
It uses a random state to simulate the success or failure of the operation.

.PARAMETER UserName
The first name of the new user.


.OUTPUTS
PSCustomObject
Returns a custom object with the following properties:
- Date: The date and time when the script was executed.
- Status: The status of the user creation process ('Success' or 'Failed').
- ScriptName: The name of the script.
- Message: A message indicating the result of the user creation process.

.EXAMPLE
.\NewUser.ps1 -FirstName John -LastName Doe -Username jdoe -Password P@ssw0rd
Creates a new user with the first name 'John', last name 'Doe', username 'jdoe', and password 'P@ssw0rd'.

.LINK
folder-remove
#>
    [CmdletBinding()]
    param (
        $OU = "OU=TestOU,DC=domain,DC=com",
        [switch]$Force = $false
    )
    
    begin {
        $ReturnObject = [PSCustomObject]@{
            Date = Get-Date
            Status = 'Success'
            ScriptName = $MyInvocation.MyCommand.Name
            Message = "OU $OU has been removed successfully"
        }
    }
    
    process {
        $State = $($false,$false,$false, $true) | Get-Random
        if($State -eq $false){
            $ReturnObject.Status = 'Failed'
            $ReturnObject.Message = "Failed to remove OU $OU"

        }
    }
    
    end {
        return $ReturnObject
    }
