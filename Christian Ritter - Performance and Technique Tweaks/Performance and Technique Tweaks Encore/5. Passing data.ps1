#Region Passing data between different run spaces

# Problem: How to pass data between different runspaces in PowerShell when they are isolated from each other?

#Region Situation 1: Global variables are not shared between runspaces

# Create a new runspace and a session state that does NOT inherit global variables
$global:MyVar = "Created in main session"
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

# Create the runspace with the isolated session state
$runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($sessionState)
$runspace.Open()

# Create a PowerShell instance and assign it to the isolated runspace
$ps = [System.Management.Automation.PowerShell]::Create()
$ps.Runspace = $runspace

# Add a script block to execute inside the isolated runspace
$ps.AddScript({
    $global:MyVar = "Should not affect main session"
    "Inside Runspace: $global:MyVar"
})

# Invoke the script
$result = $ps.Invoke()

# Close and dispose of the runspace
$ps.Dispose()
$runspace.Close()
$runspace.Dispose()

# Output the result
"Response influenced by inner runspace: $result"

# Check if the global variable was created in the main session
"Outside Runspace: $global:MyVar"

#endregion

#region Situation 2: Passing data between runspaces using runspaces data sharing


Add-Type -TypeDefinition @"
public static class ExternalDataClass
{
    private static string _myVar = "Created in class definition";

    public static string MyVar
    {
        get { return _myVar; }
        set { _myVar = value; }
    }
}
"@

[ExternalDataClass]::MyVar = "Changed in main session"

# Create a new runspace and a session state that does NOT inherit global variables
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

# Create the runspace with the isolated session state
$runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($sessionState)
$runspace.Open()

# Create a PowerShell instance and assign it to the isolated runspace
$ps = [System.Management.Automation.PowerShell]::Create()
$ps.Runspace = $runspace

# Add a script block to execute inside the isolated runspace
$ps.AddScript({
    "Inside Runspace: " + [ExternalDataClass]::MyVar
})

# Invoke the script
$result = $ps.Invoke()

# Close and dispose of the runspace
$ps.Dispose()
$runspace.Close()
$runspace.Dispose()

$Result
#endregion

# Whats about vice versa?

# Create a new runspace and a session state that does NOT inherit global variables
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

# Create the runspace with the isolated session state
$runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($sessionState)
$runspace.Open()

# Create a PowerShell instance and assign it to the isolated runspace
$ps = [System.Management.Automation.PowerShell]::Create()
$ps.Runspace = $runspace

# Add a script block to execute inside the isolated runspace
$ps.AddScript({
    [ExternalDataClass]::MyVar = "Changed in inner runspace"
})

# Invoke the script
$ps.Invoke()

# Close and dispose of the runspace
$ps.Dispose()
$runspace.Close()
$runspace.Dispose()
[ExternalDataClass]::MyVar



#Region passing functions between runspaces
# How to pass a function

# Create a new runspace and a session state that does NOT inherit global variables


# Describe the function to pass
$FunctionDefinition = @'
    return $(Get-Random -Minimum 1 -Maximum 100)
'@
    


Add-Type -TypeDefinition @"
public static class ExternalFunctionClass
{
    private static string _FunctionCode = "Function Code placeholder";

    public static string FunctionCode
    {
        get { return _FunctionCode; }
        set { _FunctionCode = value; }
    }
}
"@

[ExternalFunctionClass]::FunctionCode = $FunctionDefinition


# Create a PowerShell instance and assign it to the isolated runspace
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

# Create the runspace with the isolated session state
$runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($sessionState)
$runspace.Open()

$ps = [System.Management.Automation.PowerShell]::Create()
$ps.Runspace = $runspace

$ps.AddScript({
    ${function:Get-CustomRandom} = [scriptblock]::Create([ExternalFunctionClass]::FunctionCode)
    Get-CustomRandom
})

# Invoke the script
$ps.Invoke()
$ps.Invoke()
$ps.Invoke()

# Close and dispose of the runspace
$ps.Dispose()
$runspace.Close()
$runspace.Dispose()




#EndRegion

#Endregion

