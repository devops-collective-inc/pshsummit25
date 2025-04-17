<#
.SYNOPSIS
Creates a new Out of Office Message for a user.

.DESCRIPTION
This script creates a Out of Office Message for a user on its mailbox, please use html tags. 
It returns a custom object indicating the success or failure of the user creation process.

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
plane-car
#>




[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [String]$Text
)

begin {

    $ReturnObject = [PSCustomObject]@{
        Date = Get-Date
        Status = 'Success'
        ScriptName = $MyInvocation.MyCommand.Name
        Message = "Out of Office Message for $Username has been created successfully"
    }




}

process {
    $Result = $($false,$false,$false, $true) | Get-Random

    if($Result -eq $false){
        $ReturnObject.Status = 'Failed'
        $ReturnObject.Message = "Failed to create Out of Office Message for $Username"
    }
}

end {
    return $ReturnObject
}

