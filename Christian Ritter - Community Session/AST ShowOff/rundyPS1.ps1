function Sample-sFunction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    Write-Output "Hello, $Name!"
}