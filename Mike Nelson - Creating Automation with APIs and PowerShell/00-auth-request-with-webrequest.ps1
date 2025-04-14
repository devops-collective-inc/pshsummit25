$headers = @{ Authorization = "Bearer $token" }
$body = @{ name = "Mike"; role = "Technical Evangelist" } | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://api.company.com/users" `
    -Method Post -Headers $headers -Body $body -ContentType "application/json"

$result = $response.Content | ConvertFrom-Json
Write-Output $result.id
