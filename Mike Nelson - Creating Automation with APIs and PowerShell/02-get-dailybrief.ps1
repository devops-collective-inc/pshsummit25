# --- Daily Briefing Dashboard ---

# Variables
$latitude = 47.6061
$longitude = 122.3328
$newsApiKey = "YOUR-KEY-HERE"

# Fetch a random joke
$joke = Invoke-RestMethod "https://official-joke-api.appspot.com/random_joke"
Write-Output "$($joke.setup) ... $($joke.punchline)"

# Weather API (Open-Meteo)
$weatherResponse = Invoke-RestMethod "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true"
Write-Host "---- DAILY DASHBOARD ----`n"
Write-Host "🌤 Current Weather (Seattle):"
Write-Host ("{0}°C | Wind: {1} km/h" -f $weatherResponse.current_weather.temperature, $weatherResponse.current_weather.windspeed)

# News Headlines (NewsAPI)
$newsResponse = Invoke-RestMethod "https://newsapi.org/v2/top-headlines?country=us&category=technology&apiKey=$newsApiKey"
Write-Host "`n📰 Technology Headlines:"
$newsResponse.articles | Select-Object -First 3 | ForEach-Object {
    Write-Host "• " $_.title
}

# 3. Currency Conversion (ExchangeRate)
$currencyResponse = Invoke-RestMethod "https://open.er-api.com/v6/latest/USD"
$usdToEurRate = $currencyResponse.rates.EUR
Write-Host "`n💱 USD to EUR Exchange Rate:"
Write-Host ("1 USD = {0} EUR" -f $usdToEurRate)

# Motivational Quote (ZenQuotes.io)
$quoteResponse = Invoke-RestMethod "https://zenquotes.io/api/random"
Write-Host "`n💡 Motivational Quote:"
Write-Host ('"{0}" — {1}' -f $quoteResponse[0].q, $quoteResponse[0].a)

# Public Holidays (Nager.Date)
$year = (Get-Date).Year
$holidayResponse = Invoke-RestMethod "https://date.nager.at/api/v3/PublicHolidays/$year/US"
Write-Host "`n📅 Upcoming Holidays:"
$holidayResponse | Where-Object { (Get-Date $_.date) -ge (Get-Date) } | Select-Object -First 3 | ForEach-Object {
    Write-Host ("{0} - {1}" -f $_.date, $_.name)
}

# IP-based Geolocation (IPinfo.io)
$ipGeoResponse = Invoke-RestMethod "https://ipinfo.io/json"
Write-Host "`n📍 Your IP-based Location:"
Write-Host ("City: {0}, Region: {1}, Country: {2}" -f $ipGeoResponse.city, $ipGeoResponse.region, $ipGeoResponse.country)

# Check Status of a Website
$website = "https://www.powershell.org"
try {
    $response = Invoke-WebRequest -Uri $website -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Output "$website is UP and responding!"
    }
}
catch {
    Write-Output "$website seems DOWN or unreachable!"
}

# Daily dog picture
$url = "https://dog.ceo/api/breeds/image/random"
$response = Invoke-WebRequest $url
$json = ConvertFrom-Json $response.Content
$imageURL = $json.message
Start-Process $imageURL

Write-Host "`n---- END OF DASHBOARD ----"