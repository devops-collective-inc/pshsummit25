# --- Productivity Dashboard ---

# Display today's date/time
Write-Host "📅 Today is:" (Get-Date).ToString("dddd, MMM dd yyyy, HH:mm")

# Weather via wttr.in (No API Key required)
$weather = Invoke-RestMethod "http://wttr.in/Milwaukee?format=3"
Write-Host "`n🌤 Weather in Milwaukee: $weather"

# Check System Event Log (Last 3 Errors)
Write-Host "`n🛠 Last 3 System Errors:"
Get-EventLog -LogName System -EntryType Error -Newest 3 | Select-Object TimeGenerated, Source, Message | Format-Table -Wrap

# Check CPU Intensive Processes
Write-Host "`n🔥 Top 3 CPU-consuming processes:"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 3 Name, CPU | Format-Table

# Get Random Advice (AdviceSlip API)
$advice = (Invoke-RestMethod "https://api.adviceslip.com/advice").slip.advice
Write-Host "`n💡 Random Advice: '$advice'"

# Export summary to JSON file
$summary = @{
    Date    = (Get-Date).ToString()
    Weather = $weather
    Advice  = $advice
}
$summary | ConvertTo-Json | Out-File "$env:TEMP\daily_summary.json" -Encoding UTF8

Write-Host "`n📄 Summary saved to $env:TEMP\daily_summary.json"
