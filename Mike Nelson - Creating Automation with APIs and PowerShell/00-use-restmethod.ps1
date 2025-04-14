$response = Invoke-RestMethod -Uri "https://icanhazdadjoke.com/" -Headers @{ Accept = 'application/json' }
Write-Output $response.joke
