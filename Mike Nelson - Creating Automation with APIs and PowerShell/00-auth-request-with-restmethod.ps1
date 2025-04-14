$headers = @{ Authorization = "Bearer $token" }
$body = @{ name = "Mike"; role = "Technical Evangelist" } | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://api.company.com/users" `
    -Method Post -Headers $headers -Body $body -ContentType "application/json"

Write-Output $response.id
