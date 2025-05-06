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
                    $url = "https://www.apicountries.com/region/$continent"
                    $countries = Invoke-RestMethod -Uri $url
                    
                }
                else {
                    $url = "https://www.apicountries.com/countries"
                    $countries = Invoke-RestMethod -Uri $url
                }
                $countryNames = $countries.name | Sort-Object
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
Get-Country -Continent Americas -Country Argentina

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
        return (Invoke-RestMethod -Uri "https://www.apicountries.com/name/$Country").population
    }
    end {}
} 

$argumentCompleterScript = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $wordToComplete = $wordToComplete.trim("'")
    $url = "https://www.apicountries.com/countries"
    $countries = Invoke-RestMethod -Uri $url
    $countryNames = $countries.name | Sort-Object
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
        return (Invoke-RestMethod -Uri "https://www.apicountries.com/name/$Country").languages.name
        
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
        return (Invoke-RestMethod -Uri "https://www.apicountries.com/name/$Country").currencies
        
    }
    end {}
}

function Get-Countrylist {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    if ($wordToComplete) {
        $wordToComplete = $wordToComplete.trim("'")
    }
    
    $url = "https://www.apicountries.com/countries"
    $countries = Invoke-RestMethod -Uri $url
    $countryNames = $countries.name | Sort-Object
    $countryNames | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        if ($_.ToCharArray() -contains ' ') {
            [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
        }
        else {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}