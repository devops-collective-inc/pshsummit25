# Storing data inside ScriptScope

$Script:ModuleAData = @{
    Proxy = 'proxy1.contoso.com'
    Port = 8080
    User = 'admin'
}

Function Get-ModuleAData {
    param(
        $Key
    )
    return $Script:ModuleAData[$Key]
}

Export-ModuleMember -Function Get-ModuleAData