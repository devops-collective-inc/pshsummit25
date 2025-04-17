
#Region Native .NET Performance compared to basic loops and object handling

# Basic Fibonacci function
function Get-Fibonacci {
    param ([int]$n)
    if ($n -lt 2) { return $n }
    return (Get-Fibonacci($n - 1) + Get-Fibonacci($n - 2))
}

$Plain = Measure-Command { Get-Fibonacci 5000 } # ~Seconds to complete


Add-Type -TypeDefinition @"
public static class MathHelper {
    public static long Fibonacci(int n) {
        if (n < 2) return n;
        long a = 0, b = 1, temp;
        for (int i = 2; i <= n; i++) {
            temp = a + b;
            a = b;
            b = temp;
        }
        return b;
    }
}
"@ -Language CSharp

$DotNet = Measure-Command { [MathHelper]::Fibonacci(5000) } # Milliseconds instead of seconds!



[PSCustomObject]@{
    Plain = $Plain.TotalMilliseconds
    DotNet = $DotNet.TotalMilliseconds
}

#EndRegion

#Region Where(s), Linq and .Net Linq


$data = 1..10000 | ForEach-Object { [PSCustomObject]@{ Number = $_ } }



$WhereObject = (Measure-Command {$data | Where-Object { $_.Number -gt 5000 } }).TotalMilliseconds

$DotWhere = (Measure-Command {$data.Where({ $_.Number -gt 5000 }) }).TotalMilliseconds

$predicate = [Func[object,bool]]{ param($x); $x.Number -gt 5000}
$PowerShellLinq = (Measure-command {[System.Linq.Enumerable]::Where($data,  $Predicate)}).Milliseconds


Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Linq;

public class DataItem {
    public int Number { get; set; }
}

public static class DataHelper {
    public static List<DataItem> Filter(List<DataItem> data) {
        return data.Where(x => x.Number > 5000).ToList();
    }
}
"@ -Language CSharp
$typedData = $data | ForEach-Object { [DataItem]@{ Number = $_.Number } }
$DotNetLinq = (measure-command {[DataHelper]::Filter($typedData)}).TotalMilliseconds

[PSCustomObject]@{
    WhereObject = $WhereObject
    DotWhere = $DotWhere
    PowerShellLinq = $PowerShellLinq
    DotNetLinq = $DotNetLinq
}
#EndRegion


#Region Discover possibilities for [Ref]


function Increment-ByValue {
    param([int]$x)
    $x = $X + 1
    return $x
}



$Y = 1
Increment-ByValue $y
$Y

$Y = Increment-ByValue $Y

$y


function Increment-ByRef {
    param([ref]$x)
    $x.Value++
}
$Y = 1 
Increment-ByRef ([ref]$y)
$y


# Now we can handle output and write objects to the output stream and write information to the log list for instance 

# Generic List for logging
$LogList = [System.Collections.Generic.List[string]]::new()

function Get-APIUser {
    param(
        [ref]$LogList,
        # Parameter set for by username
        [Parameter(Mandatory = $true, ParameterSetName = 'ByUsername')]
        [string]$Username,
        # Parameter set for by ID
        [Parameter(Mandatory = $true, ParameterSetName = 'ByID')]
        [int]$ID
    )
    # Check parameter set
    if ($PSCmdlet.ParameterSetName -eq 'ByUsername') {
        $LogList.Value.Add("Getting user by username: $Username")
        # Simulate API call
        Start-Sleep -Seconds 1
        return [PSCustomObject]@{ ID = $(Get-Random -min 1 -max 1337); Username = $Username }
    } elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {
        $LogList.Value.Add("Getting user by ID: $ID")
        # Simulate API call
        Start-Sleep -Seconds 1
        return [PSCustomObject]@{ ID = $ID; Username = "User$ID" }
    }
}

function Get-APIUser {
    param(
        $LogList,
        # Parameter set for by username
        [Parameter(Mandatory = $true, ParameterSetName = 'ByUsername')]
        [string]$Username,
        # Parameter set for by ID
        [Parameter(Mandatory = $true, ParameterSetName = 'ByID')]
        [int]$ID
    )
    # Check parameter set
    if ($PSCmdlet.ParameterSetName -eq 'ByUsername') {
        $LogList.Add("Getting user by username: $Username")
        # Simulate API call
        Start-Sleep -Seconds 1
        return [PSCustomObject]@{ ID = $(Get-Random -min 1 -max 1337); Username = $Username }
    } elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {
        $LogList.Value.Add("Getting user by ID: $ID")
        # Simulate API call
        Start-Sleep -Seconds 1
        return [PSCustomObject]@{ ID = $ID; Username = "User$ID" }
    }
}

Get-APIUser -LogList ($LogList) -Username "TestUser$(Get-Random -min 1 -max 1000)"
Get-APIUser -LogList ([ref]$LogList) -ID $(Get-Random -min 1 -max 1000)

$LogList

# But calling the function with a [ref] parameter is tedious and not very readable.
# So with DefaultParameterValues we can avoid this

$PSDefaultParameterValues = @{
    'Get-API*:LogList' = [ref]$LogList

    'export-csv:Notypeinformation' = $true
}


Get-APIUser -Username "TestUser$(Get-Random -min 1 -max 1000)"

#EndRegion


#Region Lets structure our data by sorting in various ways

# Create a list of random numbers
$RandomNumbers = Get-Random -Minimum 1 -Maximum 100000000 -count 1000000


# Measure the time taken to sort the list using different methods
$PlainSort = Measure-Command { $RandomNumbers | Sort-Object } 

# Array Sort
$ArraySort = Measure-Command { [array]::Sort($RandomNumbers) } 

# Linq Sort
$LinqSort = Measure-Command { 
    $Func = [System.Func[int, int]] { param($x) $x }
    [System.Linq.Enumerable]::OrderBy([int[]]$RandomNumbers, $Func) -as [int[]]
}



# Who is the winner?
[PSCustomObject]@{
    PlainSort = $PlainSort.TotalMilliseconds
    ArraySort = $ArraySort.TotalMilliseconds
    LinqSort = $LinqSort.TotalMilliseconds
}

#EndRegion


#Region how to avoid duplicate numbers in an array

# Create a list of random numbers

$RandomNumbers = get-random -minimum 1 -Maximum 1000 -Count 1000000

$UniqueNumbersSortObjectUnique = Measure-Command {
    $RandomNumbers | Sort-Object -Unique
}

$UniqueNumbersGetUnique = Measure-Command {
    $RandomNumbers | Get-Unique
}

$UniqueNumbersHashSet = Measure-Command {
    $HashSet = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($number in $RandomNumbers) {
        $HashSet.Add($number) | Out-Null
    }
    $HashSet
}

$UniqueNumbersHashTable = Measure-Command {
    $HashTable = @{} 
    foreach ($number in $RandomNumbers) {
        $HashTable[$number] = $true
    }
    $HashTable.Keys
}

# Results
[PSCustomObject]@{
    SortObjectUnique = $UniqueNumbersSortObjectUnique.TotalMilliseconds
    GetUnique = $UniqueNumbersGetUnique.TotalMilliseconds
    HashSet = $UniqueNumbersHashSet.TotalMilliseconds
    HashTable = $UniqueNumbersHashTable.TotalMilliseconds
}

#EndRegion

#Region how to identify unique objects in an array

# Create a list of random objects
$RandomObjects = 1..5000 | ForEach-Object { [PSCustomObject]@{ ID = Get-Random -min 1 -max 10; Name = "Name$(Get-Random -min 1 -max 100)" } }

$UniqueObjectsSortHashTable = Measure-Command {
    $HashTable = @{} 
    foreach ($object in $RandomObjects) {
        $HashTable["$($object.ID)$($object.Name)"] = $object
    }
    $HashTable.Values
}


$UniqueObjectsSortObject = Measure-Command {
    $RandomObjects | Sort-Object -Unique -Property ID, Name
}

# Who is the winner?

[PSCustomObject]@{
    SortHashTable = $UniqueObjectsSortHashTable.TotalMilliseconds
    SortObject = $UniqueObjectsSortObject.TotalMilliseconds
}
#EndRegion

$objectx = [PSCustomObject]@{
    Name = "christian"
    Age = "32"
}



$HashTable = @{} 
foreach ($object in $RandomObjects) {

    
    $HashTable[($object.psobject.Properties.value -join '')] = $object
}
$HashTable.Values