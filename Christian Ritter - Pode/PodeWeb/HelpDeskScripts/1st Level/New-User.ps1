<#
.SYNOPSIS
Creates a new user in Active Directory with the specified details.

.DESCRIPTION
This script creates a new user in Active Directory using the provided first name, last name, username, and password. 
It automatically generates an email address for the user based on the provided first name and last name. 
The script returns a custom object indicating the success or failure of the user creation process.

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
account-plus
#>




[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$FirstName,

    [Parameter(Mandatory = $true)]
    [string]$LastName,

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [Parameter(Mandatory = $true)]
    [switch]$IsAdmin
)

begin {

    $ReturnObject = [PSCustomObject]@{
        Date = Get-Date
        Status = 'Success'
        ScriptName = $MyInvocation.MyCommand.Name
        Message = "User $FirstName $LastName has been created successfully"
    }
    $domain = "example.com"
    $mailSchema = "{0}.{1}@{2}" # {FirstName}.{LastName}@domain

    # Automatically fill in email address
    $Email = $mailSchema -f $FirstName, $LastName, $domain


    # Splatting for New-ADUser
    $newAdUserParams = @{
        Name              = "$FirstName.$LastName"
        GivenName         = $FirstName
        Surname           = $LastName
        SamAccountName    = $Username
        UserPrincipalName = $Email
        AccountPassword   = (ConvertTo-SecureString $Password -AsPlainText -Force)
        Enabled           = $true
        Path              = "OU=Users,DC=example,DC=com"
    }
}

process {
    $Result = $($false,$false,$false, $true) | Get-Random

    if($Result -eq $false){
        $ReturnObject.Status = 'Failed'
        $ReturnObject.Message = 'Failed to create user in Active Directory'
    }
}

end {
    return $ReturnObject
}

