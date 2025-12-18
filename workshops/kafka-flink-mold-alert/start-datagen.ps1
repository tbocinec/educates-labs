#!/usr/bin/env pwsh

Write-Host "📡 Starting Humidity Sensor Data Generator..." -ForegroundColor Cyan

Write-Host "⏳ Waiting for Kafka Connect to be ready..." -ForegroundColor Yellow
do {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8083/" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            break
        }
    } catch {
        Write-Host "   Waiting for Kafka Connect..." -ForegroundColor Gray
        Start-Sleep -Seconds 3
    }
} while ($true)

Write-Host "✅ Kafka Connect is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Registering Datagen Connector..." -ForegroundColor Cyan

# Get current timestamp in milliseconds
$currentTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

# Read the connector config
$configPath = "schemas/datagen-connector.json"
$configContent = Get-Content $configPath -Raw

# Replace the timestamp start value with current time
$updatedConfig = $configContent -replace '"start":\d+', "`"start`":$currentTimestamp"

Write-Host "⏰ Using current timestamp: $currentTimestamp" -ForegroundColor Yellow

# Submit the connector
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8083/connectors" `
        -Method Post `
        -ContentType "application/json" `
        -Body $updatedConfig

    Write-Host ""
    Write-Host "✅ Datagen connector registered!" -ForegroundColor Green
    Write-Host "📊 Generating sensor data to 'raw_sensors' topic" -ForegroundColor Cyan
    Write-Host "🔍 View connector status: http://localhost:8083/connectors/humidity-datagen-source/status" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to register connector" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

