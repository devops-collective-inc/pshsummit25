# Anatomy of a Help Desk Support Script

function New-Mailbox {
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
        [int]$MaxReceiveSizeMB = 10
    )
    
    begin {
        $Policymatch = $True
        Write-Host "Starting mailbox creation process..."
        if (-not ($EmailAddress -like "*@contoso.com")) {
            $Policymatch = $False
        }
    }
    
    process {
        # Dummy implementation

        if($Policymatch -eq $false){
            Write-Host "Email address does not conform to company policies."
        }else{
            Write-Host "Creating mailbox for $Name with email address $EmailAddress"
        
            # Simulate mailbox creation and the success
            Start-Sleep -Seconds 2
            $Result = (1..20 | ForEach-Object {
                $True, $False | Get-Random
            })[$(Get-Random -min 0 -max 19)]
        }


    }
    
    end {
        if (-not $Result) {
            Write-Host "Failed to create mailbox for $Name."
        }else{
            Write-Host "Mailbox for $Name created successfully."
            Write-Host "Mailbox creation process completed."
        }

    }
}