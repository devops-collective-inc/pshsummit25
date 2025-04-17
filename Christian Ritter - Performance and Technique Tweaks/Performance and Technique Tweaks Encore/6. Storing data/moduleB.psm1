function Get-ModuleBData{
    param ([string]$Key)
    
    # Get current module's manifest
    $module = Get-Module -Name 'moduleB' -ErrorAction SilentlyContinue
    if (-not $module) { return $null }

    return $module.PrivateData.Settings[$Key]
}