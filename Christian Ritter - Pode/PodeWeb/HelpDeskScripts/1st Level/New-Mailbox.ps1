<#
.SYNOPSIS
Creates a new user in Mailbox with the specified details.

.DESCRIPTION
This script creates a new Mailbox for the specified user. 
It returns a custom object indicating the success or failure of the user creation process.

.PARAMETER Name
The name (UPN/UserID) of the targeted user

.PARAMETER EmailAddress
The mail address the mailbox for the user that should be created.
Format should be: <username>@contoso.com

.PARAMETER MailboxSize
Define the mailbox size it could be, select from Small = 5GB, Medium = 10GB, or Large = 15GB

.PARAMETER MaxSendSizeMB
Define what is the maximum mail size that a user can send, in the Range from 1MB to 50MB

.PARAMETER MaxReceiveSizeMB
Define what is the maximum mail size that a user can receive, you can select from
5, 10, or 15

.PARAMETER LitigationHoldInDays
Define the LitigationHoldInDays only numbers are allowed


.OUTPUTS
PSCustomObject
Returns a custom object with the following properties:
- Date: The date and time when the script was executed.
- Status: The status of the user creation process ('Success' or 'Failed').
- ScriptName: The name of the script.
- Message: A message indicating the result of the user creation process.

.EXAMPLE
.\New-Mailbox.ps1 -Name John -EmailAddress john@contoso.com -Mailboxsize 'small' -MaxSendSizeInMB = 15
Creates a new user mailbox for John

.LINK
mailbox-up-outline
#>




[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$Name,
    [switch]$Force,
    [Parameter(Mandatory)]
    [string]$EmailAddress,
    [ValidateSet('Small', 'Medium', 'Large')]
    [string]$MailboxSize,
    [ValidateRange(1, 50)]
    [int]$MaxSendSizeMB = 10,
    [ValidateSet('5', '10', '15')]
    [int]$MaxReceiveSizeMB = 10,
    [int]$LitigationHoldInDays = 0
)

begin {

    $ReturnObject = [PSCustomObject]@{
        Date = Get-Date
        Status = 'Success'
        ScriptName = $MyInvocation.MyCommand.Name
        Message = "Mailbox for $username has been created successfully"
    }
}

process {
    $Result = $($false,$false,$false, $true) | Get-Random

    if($Result -eq $false){
        $ReturnObject.Status = 'Failed'
        $ReturnObject.Message = "Failed to create mailbox for $username"
    }
}

end {
    return $ReturnObject
}

