# --- Hybrid Dashboard: PowerShell + Python Curl ---

# PowerShell: Get system uptime
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
Write-Host "⏳ System Uptime: $([math]::Round($uptime.TotalHours,2)) hours"

# PowerShell: Get current user's profile size
$profileSizeMB = [math]::Round(((Get-ChildItem -Path $env:USERPROFILE -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB), 2)
Write-Host "📂 User Profile Size: $profileSizeMB MB"

# Execute Python Script for API Data (Curl)
$pythonPath = "python" # Ensure python is in PATH
$apiData = & $pythonPath "$PSScriptRoot\api_dashboard.py"
$apiResults = ConvertFrom-Json $apiData

Write-Host "`n--- API Results via Python/Curl ---"
Write-Host "🌍 Public IP: $($apiResults.public_ip)"
Write-Host "🛰 ISS Current Location: Lat $($apiResults.iss_position.latitude), Lon $($apiResults.iss_position.longitude)"
Write-Host "🐱 Random Cat Fact: $($apiResults.cat_fact)"
