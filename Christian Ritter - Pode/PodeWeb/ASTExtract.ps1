
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

    # Process each parameter and extract relevant information
    $parameters | ForEach-Object {
        [PSCustomObject]@{
            ParamName = $_.Name.VariablePath.UserPath
            ParamType = if ($_.StaticType) { $_.StaticType.Name } else { 'Unknown' }
            ParamValidationType = $_.Attributes | Where-Object { $_.TypeName.FullName -like '*Validate*' } | ForEach-Object { $_.TypeName.FullName }
            ParamValidationArguments = $_.Attributes | ForEach-Object { $_.PositionalArguments.Value }
            Mandatory = $_.Attributes.NamedArguments.ArgumentName -contains 'Mandatory'
        }
    }
}


# Example usage
$X = Get-ScriptBlockParameters -ScriptPath "$pwd\Anatomy.ps1"
$X