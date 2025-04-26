# Validate set offers tab completion for the argument, but it is limited to the values provided in the set
# No other values are allowed
function Get-Colour {
    [CmdletBinding()]
    param (
        [ValidateSet('green', 'red', 'blue')]
        [string]$Colour
    )
    begin {}
    process {
        return $Colour
    }
    end {}
}

Get-Colour -Colour


enum veggies {
    carrot
    potato
    tomato
}

# Enum based argument completer return the values of the enum. No other values are allowed
function Get-Vegetable {
    [CmdletBinding()]
    param (
        [veggies]$Vegetable
        
    )    
    begin {}
    process {
        return $Vegetable
    }
    end {}
}



# Argument completer is a script block that returns the values for the argument
# Values can be overridden by the user
# This works with Windows Powershell and Powershell
# No icon and no description. Does not work in ISE. Console and VSC only
# No Tab completion of half entered values
function Get-City {
    [CmdletBinding()]
    param (
        [ArgumentCompleter( { 'London', 'Paris', 'NewYork' } )]
        [string]$City
    )
    begin {}
    process {
        return $City
    }
    end {}
}


# ArgumentCompletions() does not work in Windows PowerShell. Only PS6 and above
# Has Icon. No ScriptBlock. Respects user input in console
function Get-Pizza {
    [CmdletBinding()]
    param (
        [ArgumentCompletions('Hawaiian', 'Pepperoni', 'Meatlovers')]
        [string]$Type
        
    )
    begin {}
    process {
        return $Type
    }
    end {}
}

Get-Pizza -Type 



# ArgumentCompleter() with dynamic values
# Same issues as with ArgumentCompleter()
function Get-MyService {
    [CmdletBinding()]
    param (
        [ArgumentCompleter( { Get-Service | Select-Object -ExpandProperty Name } )]
        [string]$ServiceName
    )
    begin {}
    process {
        return $ServiceName
    }
    end {}
}
Get-MyService -ServiceName B

# Argumentcompleter() with Icon and Description
# Icons [Enum]::GetNames("System.Management.Automation.CompletionResultType")
# like there ArgumentCompleter() and Register-ArgumentCompleter() if does not respect user input in console
# System.Management.Automation.CompletionResult new(string completionText, string listItemText, CompletionResultType resultType, string toolTip)

function Get-MyProcess {
    [CmdletBinding()]
    param (
        [ArgumentCompleter( { 
                $processNames = Get-Process | Select-Object -ExpandProperty Name 
                $processNames | ForEach-Object { 
                    [System.Management.Automation.CompletionResult]::new($_, $_ + " itemText", 'ParameterValue', $_ + ' hintText') 
                }
            })]
        [string]$ProcessName
    )
    begin {}
    process {
        return $ProcessName
    }
    end {}
}
Get-MyProcess -ProcessName 

Get-MyProcess -ProcessName 
# ArgumentCompleter that respects user input in console
function Get-DogBreed {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                $breeds = (Invoke-RestMethod https://dog.ceo/api/breeds/list/all).message.psobject.properties.name
                $breeds | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) 
                }
            })]
        [string]$Breed
    )
    begin {}
    process {
        return $Breed
    }
    end {}
}

Get-DogBreed -Breed 

# Example of argument completer using fakeBoundParameters
# This is a hashtable that contains the values of the parameters that have already been bound
# This is useful when you want to filter the values of the argument based on the value of another argument
function Get-MenuItem {
    [CmdletBinding()]
    param (
        [ValidateSet('Starter', 'Main', 'Dessert')]
        [string]$Category,

        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                $foodMenu = @{
                    "Main"    = @("Steak", "Pasta", "Burger", "Pizza")
                    "Starter" = @("Soup", "Salad", "Bruschetta", "Nachos")
                    "Dessert" = @("Cake", "IceCream", "Pie", "Cheesecake")
                }
                if ($fakeBoundParameters.ContainsKey("Category")) {
                    $category = $fakeBoundParameters["Category"]
                    $foodItems = $foodMenu[$category]
                    $foodItems | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                    }
                }
                else {
                    $allFoodItems = $foodMenu.Values | ForEach-Object { $_ }
                    $allFoodItems | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                    }
                }
            })]
        [string]$Item
    )
    begin {}
    process {
        return $Item
    }
    end {}
}


function Get-Country {
    [CmdletBinding()]
    param (
        [ValidateSet('Antarctic', 'Americas', 'Europe', 'Africa', 'Asia', 'Oceania')]
        [string]$Continent,

        [ArgumentCompleter({
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                $WordToComplete = $WordToComplete.trim("'")
                if ($FakeBoundParameters.ContainsKey('Continent')) {
                    $continent = $FakeBoundParameters['Continent']
                    $url = "https://restcountries.com/v3.1/region/$continent"
                    $countries = Invoke-RestMethod -Uri $url
                    
                }
                else {
                    $url = "https://restcountries.com/v3.1/all"
                    $countries = Invoke-RestMethod -Uri $url
                }
                $countryNames = $countries.name.official | Sort-Object
                $countryNames | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
                    if ($_.ToCharArray() -contains ' ') {
                        [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
                    }
                    else {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                    }
                }
            })]
        [string]$Country

    )
    begin {}
    process {
        return $Country
    }
    end {}
}
Get-Country -Continent Americas -Country 
# ArgumentCompleter with Register-ArgumentCompleter
# Same issues as with ArgumentCompleter()
function Get-EventLogName {
    [CmdletBinding()]
    param (
        [string]$LogName
    )
    begin {}
    process {
        return $LogName
    }
    end {}
}

Register-ArgumentCompleter -CommandName Get-EventLogName -ParameterName LogName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $eventLogName = @('Application', 'System', 'Security')
    $eventLogName | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# ArgumentCompleter with Register-ArgumentCompleter where the script is in a separate variable
function Get-Population {
    [CmdletBinding()]
    param (
        [string]$Country 
    )
    begin {}
    process {
        return (Invoke-RestMethod -Uri "https://restcountries.com/v3.1/name/$Country").population
    }
    end {}
} 

$argumentCompleterScript = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $wordToComplete = $wordToComplete.trim("'")
    $url = "https://restcountries.com/v3.1/all"
    $countries = Invoke-RestMethod -Uri $url
    $countryNames = $countries.name.official | Sort-Object
    $countryNames | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        if ($_.ToCharArray() -contains ' ') {
            [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
        }
        else {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

Register-ArgumentCompleter -CommandName Get-Population -ParameterName Country -ScriptBlock $argumentCompleterScript


<#
Some don't like that with Register-ArgumentCompleter,
because you don't know if parameter has argument completion.
You cant see it in the parameter definition. 
You can use the ArgumentCompleter attribute to do this
ArgumentCompleter() using separate script block
#>
function Get-Language {
    [CmdletBinding()]
    param (
        [ArgumentCompleter({ $argumentCompleterScript.Invoke($args) })]
        [string]$Country 
    )
    begin {}
    process {
        return (Invoke-RestMethod -Uri "https://restcountries.com/v3.1/name/$Country").languages.psobject.Properties.value
        
    }
    end {}
} 

# ArgumentCompleter using function
function Get-Currency {
    [CmdletBinding()]
    param (
        [ArgumentCompleter({ Get-Countrylist @args })]
        [string]$Country 
    )
    begin {}
    process {
        return (Invoke-RestMethod -Uri "https://restcountries.com/v3.1/name/$Country").currencies.psobject.Properties.value
        
    }
    end {}
}

function Get-Countrylist {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    if ($wordToComplete) {
        $wordToComplete = $wordToComplete.trim("'")
    }
    
    $url = "https://restcountries.com/v3.1/all"
    $countries = Invoke-RestMethod -Uri $url
    $countryNames = $countries.name.official | Sort-Object
    $countryNames | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        if ($_.ToCharArray() -contains ' ') {
            [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
        }
        else {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# multi function register argument completer in modules





