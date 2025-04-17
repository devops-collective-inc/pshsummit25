# How we could extend and give the user of our website an even better expierience?

# Parameter comments in the help synopsys could come to the rescue#



function Get-ScriptBlockParameters {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    # Ensure the script path exists
    if (-not (Test-Path -Path $ScriptPath)) {
        throw "The script path '$ScriptPath' does not exist."
    }

    # Parse the script content into an AST (Abstract Syntax Tree)
    $scriptContent = Get-Content -Path $ScriptPath -Raw
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$null, [ref]$null)

    # Traverse the AST to find parameter definitions
    $parameters = $ast.FindAll({
        param ($node)
        $node -is [System.Management.Automation.Language.ParameterAst]
    }, $true)

    # Parameter description

    $ParameterDescription = (Get-Help $ScriptPath).Parameters.parameter
    

    # Process each parameter and extract relevant information
    $parameters | ForEach-Object {
        [PSCustomObject]@{
            ParamName = $ParamName =  $_.Name.VariablePath.UserPath
            ParamType = if ($_.StaticType) { $_.StaticType.Name } else { 'Unknown' }
            ParamValidationType = $_.Attributes | Where-Object { $_.TypeName.FullName -like '*Validate*' } | ForEach-Object { $_.TypeName.FullName }
            ParamValidationArguments = $_.Attributes | ForEach-Object { $_.PositionalArguments.Value }
            Mandatory = $_.Attributes.NamedArguments.ArgumentName -contains 'Mandatory'
            Description = ($ParameterDescription | Where-Object {$_.Name -eq $ParamName}).Description.Text
        }
    }
}


# Example usage
$X = Get-ScriptBlockParameters -ScriptPath "$pwd\HelpDeskScripts\1st Level\New-Mailbox.ps1"
$X
