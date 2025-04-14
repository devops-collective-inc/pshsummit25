# Azure Server Provisioning
$azureHeaders = @{ Authorization = "Bearer YOUR_AZURE_TOKEN" }
$vmBody = @{ name = "webserver01"; location = "East US"; size = "Standard_B2s" } | ConvertTo-Json
$newServer = Invoke-RestMethod "https://management.azure.com/.../virtualMachines?api-version=2020-12-01" -Headers $azureHeaders -Body $vmBody -Method POST

# Fetch server IP
$serverDetails = Invoke-RestMethod $newServer.url -Headers $azureHeaders
$serverIP = $serverDetails.properties.networkProfile.networkInterfaces[0].ipConfigurations[0].privateIPAddress

# Cloudflare DNS Update
$cfHeaders = @{ Authorization = "Bearer YOUR_CLOUDFLARE_API_TOKEN" }
$dnsBody = @{ type = "A"; name = "webserver01.example.com"; content = $serverIP; ttl = 3600; proxied = $false } | ConvertTo-Json

Invoke-RestMethod "https://api.cloudflare.com/client/v4/zones/.../dns_records" -Headers $cfHeaders -Body $dnsBody -Method POST

Write-Host "Provisioned Azure server and updated DNS successfully."
