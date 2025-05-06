
# casting

$text = "123" 
$text.gettype() # string

[Int]$number = $text # string to int
$number.gettype() # int

[int]$number = 123.45 # double to int

# casts throw exceptions when conversion fails:
[int]$number = 'string' 

# The -as operator performs a safe type conversion, meaning:
# If the conversion succeeds, it returns the converted value
# If the conversion fails, it returns $null instead of throwing an error

"test" -as [Int]

# # uses culture-neutral conversion (US):
# [DateTime]'1980-01-30'
# [DateTime]'30.01.1980' # fails


# # uses current culture for conversion (result depends on your system):
# '30.01.1980' -as [DateTime] 
# '1980-01-30' -as [DateTime] 

# Built in transformation attribute

[PSCredential]$cred = 'TestUser'

# use the built in transformation attribute

[System.Management.Automation.Credential()][PSCredential]$cred = 'TestUser' # doesnt work
[PSCredential][System.Management.Automation.Credential()]$cred = 'TestUser' # works


function Test-Credential {
    [CmdletBinding()]
    param (
        [PSCredential]$Credential
    )
    return $Credential
}

Test-Credential -Credential (Get-Credential -UserName "Rob") 
Test-Credential -Credential 'Bob' # since ps2.0 this works too

# Creating your own Custom Transformation Attributes

function Test-SecureString {
    [CmdletBinding()]
    param (
        [securestring]$Password
    )
    return $Password
}
Test-SecureString -Password 'password' # wont work. It doesn't know how to convert string to securestring
Test-SecureString -Password (ConvertTo-SecureString 'password' -AsPlainText -Force) # works as it es of type securestring


# Custom Transformation Attributes
# allows you to pass plain text to a parameter of type securestring
class SecurestringTransformationAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [string]) {
            $secureString = ConvertTo-SecureString -String $inputData -AsPlainText -Force
        }
        else {
            $secureString = $inputData
        }
        return $secureString 
    }
}
function Test-SecureStringConversion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [SecurestringTransformation()]
        [securestring]$Password
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    return $PlainText
}

Test-SecureStringConversion -Password (ConvertTo-SecureString 'password' -AsPlainText -Force) # works
Test-SecureStringConversion -Password 'password' # works

# transformation attributes can be used with variables and not just parameters
[securestring][SecurestringTransformation()]$secureString = 'password' # works

$secureString = "bla" #Transformation attribute is bound to the variable


# another example
Get-Service -Name BITS | Restart-Service # works
$myService = Get-Service -Name BITS 
Restart-Service -Name $myService # doesnt work, because -Name only accepts string

# Custom Transformation Attributes
class ServiceTransformationAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [string]) {
            $service = Get-Service -Name $inputData
        }
        elseif ($inputData -is [System.ServiceProcess.ServiceController]) {
            $service = $inputData
        }
        else {
            throw "Input is not a valid service"
        }
        return $service 
    }    
}

function Restart-MyService {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ServiceTransformationAttribute()]
        [System.ServiceProcess.ServiceController]$Service
    )
    Write-Host "I will restart $($Service.Name)"
}

Restart-MyService -Service BITS # works. string gets converted to servicecontroller
$myService = Get-Service -Name BITS
Restart-MyService -Service $myService # works because it is already of type servicecontroller

Get-Service -Name BITS | Restart-MyService # works because it is of type servicecontroller



# Accepting an array of objects
class ProcessTransformationAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        $result = @()
        foreach ($item in $inputData) {
            if ($item -is [string]) {
                $process = Get-Process -Name $item
                if ($process) {
                    $result += $process
                }
                else {
                    throw "Process $item not found" 
                }
            }
            elseif ($item -is [System.Diagnostics.Process]) {
                $result += $item
            }
            else {
                throw "Input is not a valid process"
            }
        }
        return $result
    }    
}

function Stop-MyProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            Position = 0)]
        [ProcessTransformation()] 
        [System.Diagnostics.Process[]]$Process
    )
    Write-Host "Will stop process: $($Process.Name -join ', ')"
}

Stop-MyProcess -Process 'pwsh', 'notepad' # works
$procArray = Get-Process pwsh
Stop-MyProcess -Process $procArray



# Your function accepts a json file as input. you want to be able to pass filepath, hashtable or psobject to the function.
class JsonTransformationAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [hashtable] -or $inputData -is [PSCustomObject]) {
            return $inputData | ConvertTo-Json -Depth 10
        }
        elseif ($inputData -is [string]) {
            if (Test-Path -Path $inputData -ErrorAction SilentlyContinue) {
                $string = Get-Content -Path $inputData -Raw
            }
            else {
                $string = $inputData
            }
            #check if the string is a valid json string
            try {
                $null = $string | ConvertFrom-Json -ErrorAction Stop
                return $string
            }
            catch {
                throw "Input is not a valid JSON string"
            }
        }
        else {
            throw "Input is not a valid JSON string or hashtable"
        }
    }
}

function Get-MyJson {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            Position = 0)]
        [JsonTransformation()] 
        [String]$Json
    )
    Write-Host $Json
}

$jsonString = @'
{
    "Name": "John",
    "Surname": "Smith",
    "Address": "123 Main Street, New York, NY 10001"
}
'@
Get-MyJson -Json $jsonString # works

$faultyJsonString = @'
    "Name": "John",
    "Surname": "Smith",
    "Address": "123 Main Street, New York, NY 10001"
'@

Get-MyJson -Json $faultyJsonString # fails

# Create a hashtable
$hashtable = @{
    Name    = "John"
    Surname = "Smith"
    Address = "123 Main Street, New York, NY 10001"
}
Get-MyJson -Json $hashtable # works

# Create a PSCustomObject
$pscustomObject = [PSCustomObject]@{
    Name    = "John"
    Surname = "Smith"
    Address = "123 Main Street, New York, NY 10001"
}

Get-MyJson -Json $pscustomObject # works

# Create a JSON file
Get-MyJson -Json .\Example.json # works
Get-MyJson -Json .\Example.txt # fails because it cannot convert the text file to json


# Define a transformation attribute that ensures paths exist and converts to absolute paths. Some CLI tools require absolute paths.
class PathTransformationAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [string]) {
            if (-not (Test-Path -Path $inputData)) {
                throw [System.ArgumentException]::new("Path does not exist: $inputData")
            }
            
            return (Resolve-Path -Path $inputData).Path
        }
        throw "Cannot convert $($inputData.gettype().Name) to a valid path"
    }
}

# Use the custom transformation attribute
function Read-CustomFile {
    param(
        [Parameter(Mandatory)]
        [PathTransformation()]
        [string]$FilePath
    )
    
    Write-Output "Reading file from: $FilePath"
    
}

# Usage (will throw an error if file doesn't exist)
Read-CustomFile -FilePath ".\example.txt"
Read-CustomFile -FilePath "C:\Windows\System32\calc.exe" # works
Read-CustomFile -FilePath $hashtable # fails
