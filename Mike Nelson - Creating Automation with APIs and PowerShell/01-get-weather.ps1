$apiKey = "YOUR-KEY-HERE"
$city = "Seattle"
$response = Invoke-RestMethod "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=imperial"

if ($response.weather[0].main -match 'Clouds|Rain|Sunny|Thunderstorm|Tornado|Extreme') {
    Send-Pushover -Title "Weather for $city" -Message "Condition: $($response.weather[0].description) Temp: $($response.main[0].temp)"
}
