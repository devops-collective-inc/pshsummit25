$response = Invoke-WebRequest -Uri "https://icanhazdadjoke.com/" -Headers @{ Accept = 'application/json' }
$jokeObject = $response.Content | ConvertFrom-Json
Write-Output $jokeObject.joke
