# Class-based pseudo code

<#
    Defined functions:
    Get-VisualEffectInstance

    Defined classes:
    VisualEffectRegistry
    VisualEffectSPI
#>


function Set-VisualEffect {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]
        $Name,

        [bool]
        $Enabled
    )

    $effect = Get-VisualEffectInstance -Name $Name
    if ($effect.Enabled -ne $Enabled) {
        if ($PSCmdlet.ShouldProcess($Name, "Set effect to $Enabled")) {
            $effect.Set($Enabled)
        }
    }
}
