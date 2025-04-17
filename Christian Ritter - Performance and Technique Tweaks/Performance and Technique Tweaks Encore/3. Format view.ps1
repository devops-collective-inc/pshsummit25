#Region Format view (XML)

# Your Terminal can do this

$ImagePath = '.\Performance and Technique Tweaks Encore\NGGYU.webp'
Write-Host "$ImagePath"

# Your Terminal can do this as well

$Files = Get-ChildItem -Path ".\Performance and Technique Tweaks Encore" 
$Files.FullName

# But can it do this?
$Files

# It can, because I use an amazing module called TerminalIcons, but what if I want to have this behavior with out that module?


# let's see if we can make it do this

# Option 1: Custom Select-Object with ANSI Support
$Files | Select-Object -Property Mode, LastWriteTime, Length, @{Name='Name';Expression={"`e]8;;$($_.FullName)`e\$($_.Name)`e]8;;`e\"}}

# Option 2: Custom Format-Table with ANSI Support
$Files | Format-Table -Property Mode, LastWriteTime, Length, @{Name='Name';Expression={"`e]8;;$($_.FullName)`e\$($_.Name)`e]8;;`e\"}}

# Option 3: Custom Format-List with ANSI Support
$Files | Format-List -Property Mode, LastWriteTime, Length, @{Name='Name';Expression={"`e]8;;$($_.FullName)`e\$($_.Name)`e]8;;`e\"}}

$Properties = @(
    @{Name='Mode';Expression={$_.Mode}},
    @{Name='LastWriteTime';Expression={$_.LastWriteTime}},
    @{Name='Length';Expression={$_.Length}},
    @{Name='Name';Expression={"`e]8;;$($_.FullName)`e\$($_.Name)`e]8;;`e\"}}
)

(get-ChildItem -Path ".\Performance and Technique Tweaks Encore")| New-PSFormatXML -properties $Properties -ViewName 'BGCI' -Path .\BetterGCI.format.ps1xml -FormatType "Table" -PassThru



Update-FormatData  .\BetterGCI.format.ps1xml 

$Files | Format-Table -View BGCI

# How to make this available?

# Option 1: Create proxy function for Get-ChildItem

function bgci {Get-ChildItem | Format-Table -view BGCI}

# Prepandpath 
<#
    -PrependPath
Specifies formatting files that this cmdlet adds to the session. 
The files are loaded before PowerShell loads the built-in formatting files.

When formatting .NET objects, PowerShell uses the first formatting definition that it finds 
for each .NET type. If you use the PrependPath parameter, 
PowerShell searches the data from the files that you are adding before it encounters the formatting data
from the built-in files.

Use this parameter to add a file that formats a .NET object 
that is also referenced in the built-in formatting files.


#>

Update-FormatData -PrependPath .\BetterGCI.format.ps1xml 


#Region Helping links
<#
    Jeff Hicks Blog - Create easy custom formatting - detailed Walkthrough
    https://jdhitsolutions.com/blog/powershell/7774/easy-powershell-custom-formatting/

    Jeff Hicks Module - PSScriptTools - Simplify the process of creating custom formatting files (next to other gems)
    https://github.com/jdhitsolutions/PSScriptTools

#>


#EndRegion


#EndRegion Format view (XML)




