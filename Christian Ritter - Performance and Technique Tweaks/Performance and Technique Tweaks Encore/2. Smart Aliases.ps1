#Region Smart Aliases

# Smart Aliases 

#Region Helper
function Invoke-APIRestMethod {
    [CmdletBinding()]
    param (
        $Method,
        $Uri
    )
    
    begin {
        $Resource = $Uri.replace('https://api.example.com/', '').split('/')[0]
        $Identity = $Uri.replace('https://api.example.com/', '').split('/')[1]
    }
    
    process {

        Write-Host "Using Method: '$Method' on Resource: '$Resource' for Identity: '$Identity'"
    }
    
    end {
        
    }
}
#EndRegion Helper
# Bad:

function Get-APIUser {
    [CmdletBinding()]
    param (
        $Identity
    )
    
    begin {
    }
    
    process {
        $Users = Invoke-APIRestMethod -Uri "https://api.example.com/users/$Identity" -Method Get
        
    }
    
    end {
        return $Users
    }
}

function Get-APIDevice {
    [CmdletBinding()]
    param (
        $Identity
    )
    
    begin {
    }
    
    process {
        $Device = Invoke-APIRestMethod -Uri "https://api.example.com/devices/$Identity" -Method Get
        
    }
    
    end {
        return $Device
    }
}

function Get-APIApplication {
    [CmdletBinding()]
    param (
        $Identity
    )
    
    begin {
    }
    
    process {
        $Application = Invoke-APIRestMethod -Uri "https://api.example.com/Application/$Identity" -Method Get
    }
    
    end {
        return $Application
    }
}

# Good:

function Get-APIV2 {
    [CmdletBinding()]
    param (
        $Identity,
        [ValidateSet("users", "devices", "applications")]
        $Resource
    )
    
    begin {
    }
    
    process {
        $Return = Invoke-APIRestMethod -Uri "https://api.example.com/$Resource/$Identity" -Method Get
    }
    
    end {
        return $Return
    }
}

# Better:





function Get-APIv3 {
    [CmdletBinding()]
    [Alias("Get-APIv3User", "Get-APIv3Device", "Get-APIv3Application")]

    param (
        $Identity
    )
    
    begin {

        # Get the name of the function that was called and extract the resource
        $Resource = ($MyInvocation.InvocationName).Replace($MyInvocation.MyCommand.Name, '')
        # Build the URI
        $Uri = "https://api.example.com/$Resource/$Identity"
    }
    
    process {
        if([string]::IsNullOrEmpty($Resource)){
            Write-Host 'Function name must be in the format Get-APIv3Resource'
            return
        }
        $ReturnObject = Invoke-APIRestMethod -Uri $Uri -Method Get
    }
    
    end {
        return $ReturnObject
    }
}

# Explanation: InvocationName and MyCommand.Name

function Get-FunctionName {
    
    [CmdletBinding()]
    [Alias("Get-FunctionNameAlias")]
    param (
        
    )
    
    begin {
        # Get the name of the actual function that was called
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Host "Function Name: $FunctionName"

        # Get the name of the alias that was called
        $AliasName = $MyInvocation.InvocationName
        Write-Host "Alias Name: $AliasName"

        # subtract the actual function name from the alias name to get the Alias used
        $AliasUsed = $AliasName.Replace($FunctionName, '')
        Write-Host "Alias Used: $AliasUsed"
    }
    
    process {
        
    }
    
    end {
        
    }
}

# Be aware of case sensitivity

Get-APIv3User -identity Christian
Get-APIV3USER -identity Christian

# Solution: Just upper Alias and function name

function Get-APIv3 {
    [CmdletBinding()]
    [Alias("Get-APIv3User", "Get-APIv3Device", "Get-APIv3Application")]

    param (
        $Identity
    )
    
    begin {

        # Get the name of the function that was called and extract the resource
        $Resource = ($MyInvocation.InvocationName).ToUpper().Replace($MyInvocation.MyCommand.Name.ToUpper(), '')
        # Build the URI
        $Uri = "https://api.example.com/$Resource/$Identity"
    }
    
    process {
        if([string]::IsNullOrEmpty($Resource)){
            Write-Host 'Function name must be in the format Get-APIv3Resource'
            return
        }
        $ReturnObject = Invoke-APIRestMethod -Uri $Uri -Method Get
    }
    
    end {
        return $ReturnObject
    }
}


Get-APIv3User -identity Christian
Get-APIV3USER -identity Christian

# if you are a fan of regex, you can also use regex to extract the resource name from the function name
function Get-APIv3[beta] {
    [CmdletBinding()]
    [Alias("Get-APIv3[beta]User", "Get-APIv3[beta]Device", "Get-APIv3[beta]Application")]

    param (
        $Identity
    )
    
    begin {

        # Get the name of the function that was called and extract the resource
        $Resource = $MyInvocation.InvocationName -replace [regex]::Escape($MyInvocation.MyCommand.Name), ''
        # Build the URI
        $Uri = "https://api.example.com/$Resource/$Identity"
    }
    
    process {
        if([string]::IsNullOrEmpty($Resource)){
            Write-Host 'Function name must be in the format Get-APIv3Resource'
            return
        }
        $ReturnObject = Invoke-APIRestMethod -Uri $Uri -Method Get
    }
    
    end {
        return $ReturnObject
    }
}

Get-APIv3[beta]user -Identity "Christian"
Get-APIv3[beta]User -Identity "Christian"



# Best:



function Get-APIv4 {
    [CmdletBinding()]
    param (
        $Identity
    )
    
    begin {
        
        # Get the name of the function that was called and extract the resource
        $Resource = ($MyInvocation.InvocationName).ToUpper().Replace($MyInvocation.MyCommand.Name.ToUpper(), '')

        # Build the URI
        $Uri = "https://api.example.com/$Resource/$Identity"
    }
    
    process {
        if([string]::IsNullOrEmpty($Resource)){
            Write-Host 'Function name must be in the format Get-APIv3Resource'
            return
        }
        $ReturnObject = Invoke-APIRestMethod -Uri $Uri -Method Get
    }
    
    end {
        return $ReturnObject
    }
}

# Build the aliases externally

$Resources = @("User", "Device", "Application", 'ManagedApplication')

foreach($Resource in $Resources){
    New-Alias -Name "Get-APIv4$Resource" -Value Get-APIv4 -Force
}

#EndRegion Smart Aliases



# Putting it all together


function Get-APICountries {
    param (
        
    )
    $Countries = Invoke-RestMethod -Uri 'https://countriesnow.space/api/v0.1/countries' -Method Get
    return $Countries.data.country
}

function Get-APICities {
    param (
        $country
    )

    if($MyInvocation.MyCommand.Name.ToUpper() -eq $MyInvocation.InvocationName.ToUpper()){
        if([string]::IsNullOrEmpty($country)){
            Write-Host 'You need to provide a country, as the country is not in the command name'
            return
        }
    }else{
        $country = ($MyInvocation.InvocationName).ToUpper().Replace($MyInvocation.MyCommand.Name.ToUpper(), '')
        if(-not [string]::IsNullOrEmpty($country)){
            Write-Warning 'You provided a country, but it is not needed'
        }
    }

    $cityQueryParams = @{
        Body = @{ country = $country } |ConvertTo-Json -Compress
        Uri = 'https://countriesnow.space/api/v0.1/countries/cities'
        Method = 'Post'
        ContentType = 'application/json'
    }
    
    (Invoke-RestMethod @cityQueryParams).data
    # Without splatting
    #(Invoke-RestMethod -Uri 'https://countriesnow.space/api/v0.1/countries/cities' -Body (@{ country = $country } |ConvertTo-Json -Compress) -Method 'post' -ContentType 'application/json').data
}



$AllCountries = Get-APICountries

$AllCountries.ForEach({
    New-Alias -Name "Get-APICities$_" -Value Get-APICities -Force
})

# Register argument completer for Get-APICities
Register-ArgumentCompleter -CommandName Get-APICities -ParameterName country -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $AllCountries | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            $_,
            $_,
            [System.Management.Automation.CompletionResultType]::ParameterValue,
            $_
        )
    }
}

Get-ApiCities -country 'North Korea'
Get-APICitiesGermany
Get-APICities
Get-APICitiesGermany -country 'Australia'


# If we are running good on time, 
# we can also tweak the Get-APICities function to add the country parameter dynamically 
# if its called by the actual function name

function Get-APICitiesV2 {
    [CmdletBinding()]
    Param()
    dynamicparam {
        # Check if the function was called by its actual name
        if ($MyInvocation.MyCommand.Name.ToUpper() -eq $MyInvocation.InvocationName.ToUpper()) {
            # Create the dictionary for dynamic parameters
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Define the parameter name
            $paramName = "Country"

            # Define the attribute collection
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $paramAttribute = New-Object System.Management.Automation.ParameterAttribute
            $paramAttribute.Mandatory = $true  # Make it mandatory
            $attributeCollection.Add($paramAttribute)

            # Create the dynamic parameter
            $dynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($paramName, [string], $attributeCollection)

            # Add it to the dictionary
            $paramDictionary.Add($paramName, $dynParam)

            return $paramDictionary
        }
    }

    begin {
        
        if($PSBoundParameters.ContainsKey("Country")){
            # Get the country from the parameter Country this needs to be written like that if you parameter is dynamic
            $Country = $PSBoundParameters["Country"]
        }else{
            $Country = ($MyInvocation.InvocationName).ToUpper().Replace($MyInvocation.MyCommand.Name.ToUpper(), '')
        }
    }

    process {
        $cityQueryParams = @{
            Body = @{ country = $country } |ConvertTo-Json -Compress
            Uri = 'https://countriesnow.space/api/v0.1/countries/cities'
            Method = 'Post'
            ContentType = 'application/json'
        }
        
        (Invoke-RestMethod @cityQueryParams).data
    }

    end {
        return $Result
    }
}

$AllCountries.ForEach({
    New-Alias -Name "Get-APICitiesV2$_" -Value Get-APICitiesV2 -Force
})

# Register argument completer for Get-APICities
Register-ArgumentCompleter -CommandName Get-APICitiesV2 -ParameterName country -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $AllCountries | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            $_,
            $_,
            [System.Management.Automation.CompletionResultType]::ParameterValue,
            $_
        )
    }
}

Get-APICitiesV2 -country 'North Korea'
Get-APICitiesV2Germany
Get-APICitiesV2Germany -country 'United States'
Get-APICitiesV2