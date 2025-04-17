



$Dict = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)

$Dict['Username'] = 'Christian'
$Dict['Password'] = 'I_am_bat_man123'
$Dict['ClientId'] = '1337'

$FrozenDict = [System.collections.frozen.FrozenDictionary]::ToFrozenDictionary[string,string]($Dict)

Remove-Variable $Dict -force


function Get-ModuleEData {
    param(
        $Key
    )
    return $FrozenDict[$Key]
}

Export-ModuleMember -Function Get-ModuleEData


