<#
.SYNOPSIS
Deactivates a user in Active Directory based on the provided username.

.DESCRIPTION
This script creates deactivates a user in Active Directory based on the provided username

.PARAMETER FirstName
The first name of the new user.

.PARAMETER LastName
The last name of the new user.

.PARAMETER Username
The username for the new user.

.PARAMETER Password
The password for the new user.

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
account-minus-outline
#>

param(
	[string]$Username
)

begin{


	$ReturnObject = [PSCustomObject]@{
        Date = Get-Date
        Status = 'Success'
        ScriptName = $MyInvocation.MyCommand.Name
        Message = "User $Username has been deactivated"
    }
	if(-not ($($true,$true,$true,$False | get-random))){
		$ReturnObject.Status = 'Failed'
		$Message = "Could not find $UserName in Active Directory"
	}
}

process {
	# User has been deactivated
}

end{
	return $ReturnObject
}
