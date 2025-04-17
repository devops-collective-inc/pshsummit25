#Region Adding to arrays
# True: Adding via += was bad for a long long time. 
# False: It is still bad. (when you use PowerShell 7.5+)

# Adding Elements to an Array Windows PowerShell

(measure-command {
    $Array = @(); 1..10000 | ForEach-Object { $Array += $_ };
}).TotalMilliseconds

# But what to use if we are below version 7.5?

# Bad: ArrayLists
# Even if some people still promote ArrayLists, they are not the best choice.
# They cause some overhead which we have to avoid and is officially deprecated.
# Deprecation statement: https://learn.microsoft.com/en-us/dotnet/api/system.collections.arraylist?view=net-8.0

(measure-command {
    $ArrayList = New-Object System.Collections.ArrayList
    1..10000| ForEach-Object { $ArrayList.Add($_) }
}).TotalMilliseconds

# Good: Generic Lists
# Generic Lists are the best choice for adding elements to an array in Windows PowerShell.
# They are faster than ArrayLists and have no overhead.

(measure-command {
    $List = New-Object System.Collections.Generic.List[object]
    1..10000 | ForEach-Object { $List.Add($_) }
}).TotalMilliseconds # 20747.8662

# Best: Update to PowerShell 7.5+

winget install --id Microsoft.PowerShell --source winget 


# Thanks Jordan!!!!
#EndRegion