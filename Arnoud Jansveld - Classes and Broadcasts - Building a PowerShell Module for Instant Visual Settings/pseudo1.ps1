# Pseudo code

$script:registryEffects = @(...)
<#
    Defined functions:
    Get-RegistryEffect
    Get-ApiEffect
    Set-RegistryEffect
    Set-ApiEffect
#>

function Get-VisualEffect {
    [CmdletBinding()]
    param (
        [string]
        $Name
    )

    if ($Name -in $registryEffects) {
        Get-RegistryEffect $Name
    }
    else {
        Get-ApiEffect $Name
    }
}


#v1
function Set-VisualEffect {
    [CmdletBinding()]
    param (
        [string]
        $Name,

        [bool]
        $Enabled
    )

    if ($Name -in $registryEffects) {
        Set-RegistryEffect $Name $Enabled
    }
    else {
        Set-ApiEffect $Name $Enabled
    }
}

#v2
function Set-VisualEffect {
    [CmdletBinding()]
    param (
        [string]
        $Name,

        [bool]
        $Enabled
    )

    if ($Name -in $registryEffects) {
        if ((Get-RegistryEffect $Name) -ne $Enabled) {
            Set-RegistryEffect $Name $Enabled
        }
    }
    else {
        if ((Get-ApiEffect $Name) -ne $Enabled) {
            Set-ApiEffect $Name $Enabled
        }
    }
}

#v3
function Set-VisualEffect {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]
        $Name,

        [bool]
        $Enabled
    )

    if ($Name -in $registryEffects) {
        if ((Get-RegistryEffect $Name) -ne $Enabled) {
            if ($PSCmdlet.ShouldProcess($Name, "Set effect to $Enabled")) {
                Set-RegistryEffect $Name $Enabled
            }
        }
    }
    else {
        if ((Get-ApiEffect $Name) -ne $Enabled) {
            if ($PSCmdlet.ShouldProcess($Name, "Set effect to $Enabled")) {
                Set-ApiEffect $Name $Enabled
            }
        }
    }
}

