
# Method 1: Storing data in module via script scope
import-module ".\performance and Technique Tweaks Encore\6. Storing data\moduleA.psm1"
Get-ModuleAData -Key 'Proxy'

# we cant access the data directly
$Script:ModuleAData['Proxy']
get-variable -Name ModuleAData -Scope global

# Method 2: Storing PrivateData in the psd1 file
import-module ".\performance and Technique Tweaks Encore\6. Storing data\moduleB.psd1" -force
Get-ModuleBData -Key 'Timeout'
# Other way to access the data:
$module = Get-Module -Name 'moduleB' -ErrorAction SilentlyContinue

$module.PrivateData.Settings['Timeout']

# can we change the data?
$module.PrivateData.Settings['Timeout'] = 60

$module.PrivateData.Settings['Timeout']

# we cant change those settings persistently

# Method 3: Storing data in a separate psd1 file
import-module ".\performance and Technique Tweaks Encore\6. Storing data\moduleC.psm1" -force
Get-ModuleCData -Key 'Timeout'

Set-ModuleCData -Key 'Timeout' -Value 60

# Question: how to store data that is not immutable
# we could try to use constant and readonly variables

# Creating a ReadOnly variable
$myArray = @(1, 2, 3)
Set-Variable -Name myVar -Value $myArray -Option ReadOnly

# Trying to reassign a new value (This will fail)
try {
    $myVar = @(4, 5, 6)
} catch {
    Write-Host "Reassignment failed: $($_.Exception.Message)"
}

# Modifying the contents of the array (This will succeed)
$myVar[0] = 42
Write-Host "Modified array: $myVar"

# Creating a Constant variable
Set-Variable -Name myConst -Value @{ Key = "Value" } -Option Constant

# Trying to reassign (This will fail)
try {
    $myConst = @{ NewKey = "NewValue" }
} catch {
    Write-Host "Reassignment failed: $($_.Exception.Message)"
}

# Modifying the hashtable contents (This will succeed)
$myConst["Key"] = "ReallyNewValue"
Write-Host "Modified hashtable: $($myConst.values)"


<# Explain:

    The options ReadOnly and Constant are variable (data-holder) concepts: 
    they only prevent assigning a new value to the variable, 
    they don't prevent modification of the value that a read-only/constant variable immutably stores.
#>

# how to store data that is not immutable

Set-Variable -Option ReadOnly, AllScope -Name STANDARD_TOKEN_PARAMS -Value $(
    $dict = [System.Collections.Generic.Dictionary[string, string]]::new(
      [System.StringComparer]::OrdinalIgnoreCase # Case-insensitive key comparison is used.
    )
    $dict.Add('Username', 'Christian')
    $dict.Add('Password', 'I_am_bat_man123')
    $dict.Add('ClientId', '1337')
    [System.Collections.ObjectModel.ReadOnlyDictionary[string, string]]::new($dict)
)

$STANDARD_TOKEN_PARAMS['Username'] 
$STANDARD_TOKEN_PARAMS['Username'] = 'Ben Reader'

$STANDARD_TOKEN_PARAMS = [System.Collections.Generic.Dictionary[string, string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase # Case-insensitive key comparison is used.
)


<# SideNote:
    Unfortunately, you cannot directly initialize a ReadOnlyDictionary[TKey, TValue] instance from a PowerShell [hashtable],
    because a generic IDictionary-implementing instance with matching types is required;
     therefore, an auxiliary System.Collections.Generic.Dictionary[TKey, TValue] instance is used.
#>

# Lets try to remove the variable and write a new one:

Remove-Variable -Name STANDARD_TOKEN_PARAMS

# we need more power

Remove-Variable -Name STANDARD_TOKEN_PARAMS -Force

# build it again

Set-Variable -Option ReadOnly, AllScope -Name STANDARD_TOKEN_PARAMS -Value $(
    $dict = [System.Collections.Generic.Dictionary[string, string]]::new(
      [System.StringComparer]::OrdinalIgnoreCase
    )
    $dict.Add('Username', 'Ben Reader')
    $dict.Add('Password', 'I_owe_my_soul_to_the_company_store123')
    $dict.Add('ClientId', '42')
    [System.Collections.ObjectModel.ReadOnlyDictionary[string, string]]::new($dict)
)

$STANDARD_TOKEN_PARAMS['Username'] 

# Shamelessly stole from: https://stackoverflow.com/questions/66857718/is-it-possible-to-create-a-non-modifiable-hashtable-in-powershell


# Method 4: Storing not immutable data in a module

import-module ".\performance and Technique Tweaks Encore\6. Storing data\moduleD.psm1" -force
Get-ModuleDData -Key 'Username'

# Shout out to Santiago Squarzon for this neat trick to manipulate the data

$Dict = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$Dict['Username'] = 'Christian'
$Dict['Password'] = 'I_am_bat_man123'
$Dict['ClientId'] = '1337'
$ReadOnlyDict = [System.Collections.ObjectModel.ReadOnlyDictionary[string, string]]::new($Dict)
$ReadOnlyDict

$a = [System.Collections.ObjectModel.ReadOnlyDictionary[string, string]].GetField(
    'm_dictionary', [System.Reflection.BindingFlags] 'NonPublic, Instance'
    ) | foreach-Object {
        $_.GetValue($ReadOnlyDict)
    }
$a
$a['Username'] = 'Ben Reader'
$a

$ReadOnlyDict

$ReadOnlyDict['username'] = "Christian again"

# Method 5: Use Frozen Dictionary

$Dict = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$Dict['Username'] = 'Elsa'
$Dict['Password'] = 'Let-It-Go123'
$Dict['ClientId'] = '1337'
$FrozenDict = [System.collections.frozen.FrozenDictionary]::ToFrozenDictionary[string,string]($Dict)

$FrozenDict['Username']
$FrozenDict['Username'] = "Sven"

# it is not immutable, but I can override the variable and create a new one

$Dict = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$Dict['Username'] = 'Jeffrey Snover'
$Dict['Password'] = 'I_am_bat_man123'
$Dict['ClientId'] = '1337'
$FrozenDict = [System.collections.frozen.FrozenDictionary]::ToFrozenDictionary[string,string]($Dict)

$FrozenDict['Username']
$FrozenDict['Username'] = "Ben Reader"

# lets combine everything we learned so far

Set-Variable -Option ReadOnly, AllScope -Name STANDARD_TOKEN_PARAMS_FROZEN -Value $(
    $Dict = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $Dict['Username'] = 'Christian'
    $Dict['Password'] = 'I_am_bat_man123'
    $Dict['ClientId'] = '1337'
    [System.collections.frozen.FrozenDictionary]::ToFrozenDictionary[string,string]($Dict)
)

$STANDARD_TOKEN_PARAMS_FROZEN['Username']




# Method 6: Storing data in a module and converting it to a Frozen Dictionary

import-module ".\performance and Technique Tweaks Encore\6. Storing data\moduleE.psm1" -force
Get-ModuleEData -Key 'Username'