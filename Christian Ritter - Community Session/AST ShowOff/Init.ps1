Set-Location -Path ".\2025\"
Import-Module PSScriptanalyzer

function prompt{
    "#PSHSummit DangerZone >"
}

# Choose your Destiny Cowboy
Invoke-ScriptAnalyzer -CustomRulePath ".\AST ShowOff\Measure-SnakeCaseVariableNames.psm1" -Path ".\AST ShowOff"
Invoke-ScriptAnalyzer -CustomRulePath ".\AST ShowOff\Measure-PermissionScope.psm1" -Path ".\AST ShowOff"
Invoke-ScriptAnalyzer -CustomRulePath ".\AST ShowOff\Measure-CommandExampleAnalyzer.psm1" -Path ".\AST ShowOff"
