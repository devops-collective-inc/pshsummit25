$Script:ModuleCDefaults = Import-PowerShellDataFile -path $PSScriptRoot\moduleCConfig.psd1 

Function Get-ModuleCData {
    param(
        $Key
    )
    return $Script:ModuleCDefaults[$Key]
}

function Set-ModuleCData {
    param(
        $Key,
        $Value
    )
    $Script:ModuleCDefaults[$Key] = $Value
}
Export-ModuleMember -Function Get-ModuleCData, Set-ModuleCData

