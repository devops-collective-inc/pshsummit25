Set-Variable -Option ReadOnly -scope script -Name ModuleCDefaults -Value $(
    $dict = [System.Collections.Generic.Dictionary[string, string]]::new(
      [System.StringComparer]::OrdinalIgnoreCase
    )
    $dict.Add('Username', 'Ben Reader')
    $dict.Add('Password', 'I_owe_my_soul_to_the_company_store123')
    $dict.Add('ClientId', '42')
    [System.Collections.ObjectModel.ReadOnlyDictionary[string, string]]::new($dict)
)

Function Get-ModuleDData {
    param(
        $Key
    )
    return $Script:ModuleCDefaults[$Key]
}