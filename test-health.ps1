#!/usr/bin/env powershell

# Training Services - System Health Check
# Tests all microservices and inter-service communication

Write-Host "=== Training Services Health Check ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$timeout = 5  # seconds
$maxWait = 60  # seconds to wait for services to be ready

Write-Host "Waiting for services to start (max $maxWait seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Define service endpoints
$services = @(
    @{ Name = "Discovery Server (Eureka)"; URL = "http://localhost:8761/eureka/apps"; Port = 8761 },
    @{ Name = "Config Server"; URL = "http://localhost:8888/actuator/health"; Port = 8888 },
    @{ Name = "API Gateway"; URL = "http://localhost:8080/actuator/health"; Port = 8080 },
    @{ Name = "Course Service"; URL = "http://localhost:8081/actuator/health"; Port = 8081 },
    @{ Name = "Enrollment Service"; URL = "http://localhost:8082/actuator/health"; Port = 8082 }
)

# Health check function
function Test-ServiceHealth {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$Port
    )
    
    # First check if port is open
    $portOpen = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue | Select-Object -ExpandProperty TcpTestSucceeded
    
    if (-not $portOpen) {
        Write-Host "  ✗ $ServiceName - NOT STARTED (port $Port closed)" -ForegroundColor Red
        return $false
    }
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec $timeout -SkipHttpErrorCheck
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $ServiceName - HEALTHY (port $Port)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ⚠ $ServiceName - Status $($response.StatusCode) (port $Port)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "  ⏳ $ServiceName - STARTING... (port $Port)" -ForegroundColor Gray
        return $false
    }
}

# Check services repeatedly
$allHealthy = $false
$elapsed = 0
$interval = 5

while (-not $allHealthy -and $elapsed -lt $maxWait) {
    Write-Host ""
    Write-Host "Health check at $elapsed seconds..." -ForegroundColor Gray
    
    $healthyCount = 0
    foreach ($service in $services) {
        if (Test-ServiceHealth -ServiceName $service.Name -Url $service.URL -Port $service.Port) {
            $healthyCount++
        }
    }
    
    if ($healthyCount -eq $services.Count) {
        $allHealthy = $true
    } else {
        Write-Host "  ($healthyCount/$($services.Count) services healthy)" -ForegroundColor Gray
        Start-Sleep -Seconds $interval
        $elapsed += $interval
    }
}

Write-Host ""
Write-Host "=== Health Check Results ===" -ForegroundColor Cyan

if ($allHealthy) {
    Write-Host "✓ All services are HEALTHY!" -ForegroundColor Green
    Write-Host ""
    
    # Test inter-service communication
    Write-Host "Testing API endpoints..." -ForegroundColor Yellow
    
    try {
        Write-Host ""
        Write-Host "1. Testing Course Service API:" -ForegroundColor Cyan
        $courseResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/courses" -TimeoutSec $timeout -SkipHttpErrorCheck
        Write-Host "   GET /api/courses -> $($courseResponse.StatusCode)" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "2. Testing Enrollment Service API:" -ForegroundColor Cyan
        $enrollResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/enrollments" -TimeoutSec $timeout -SkipHttpErrorCheck
        Write-Host "   GET /api/enrollments -> $($enrollResponse.StatusCode)" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "3. Testing Eureka Service Registry:" -ForegroundColor Cyan
        $eurekaResponse = Invoke-WebRequest -Uri "http://localhost:8761/eureka/apps" -TimeoutSec $timeout -SkipHttpErrorCheck
        Write-Host "   GET /eureka/apps -> $($eurekaResponse.StatusCode)" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "✓ All API endpoints responding!" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error testing endpoints: $_" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Services are still starting or not responding" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check individual terminal windows for errors." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Service URLs ===" -ForegroundColor Cyan
Write-Host "  API Gateway:      http://localhost:8080" -ForegroundColor White
Write-Host "  Discovery Server: http://localhost:8761" -ForegroundColor White
Write-Host "  Config Server:    http://localhost:8888" -ForegroundColor White
Write-Host "  Course Service:   http://localhost:8081 (via gateway /api/courses)" -ForegroundColor White
Write-Host "  Enrollment Svc:   http://localhost:8082 (via gateway /api/enrollments)" -ForegroundColor White
Write-Host ""

# Return exit code
exit $(if ($allHealthy) { 0 } else { 1 })
