#!/usr/bin/env powershell

# Training Services - Run All Microservices
# This script starts all 5 microservices in separate terminal windows

param(
    [switch]$Sequential = $false,  # If $true, starts one after another instead of parallel
    [string]$JavaHome = "C:\Program Files\Java\jdk-21.0.10"
)

Write-Host "=== Training Services Microservices Launcher ===" -ForegroundColor Cyan
Write-Host "Starting 5 microservices..." -ForegroundColor Yellow
Write-Host ""

# Set Java Home
$env:JAVA_HOME = $JavaHome
Write-Host "Java Home: $env:JAVA_HOME" -ForegroundColor Green

# Services to start (order matters: start Eureka first, then Config Server, then others)
$services = @(
    @{
        Name = "Discovery Server (Eureka)"
        Dir = "discovery-server"
        Port = 8761
        Jar = "discovery-server-0.0.1-SNAPSHOT.jar"
        Order = 1
    },
    @{
        Name = "Configuration Server"
        Dir = "config-server"
        Port = 8888
        Jar = "config-server-0.0.1-SNAPSHOT.jar"
        Order = 2
    },
    @{
        Name = "API Gateway"
        Dir = "api-gateway"
        Port = 8080
        Jar = "api-gateway-0.0.1-SNAPSHOT.jar"
        Order = 3
    },
    @{
        Name = "Course Service"
        Dir = "course-service"
        Port = 8081
        Jar = "course-service-0.0.1-SNAPSHOT.jar"
        Order = 4
    },
    @{
        Name = "Enrollment Service"
        Dir = "enrollment-service"
        Port = 8082
        Jar = "enrollment-service-0.0.1-SNAPSHOT.jar"
        Order = 5
    }
)

# Sort by order
$services = $services | Sort-Object { $_.Order }

# Start services
foreach ($service in $services) {
    $serviceName = $service.Name
    $serviceDir = $service.Dir
    $servicePort = $service.Port
    $jarFile = $service.Jar
    $workingDir = "d:\NetBeansProjects\TrainingServices\$serviceDir"
    
    Write-Host "Starting: $serviceName (Port: $servicePort)..." -ForegroundColor Cyan
    
    # Check if JAR exists
    $jarPath = "$workingDir\build\libs\$jarFile"
    if (-not (Test-Path $jarPath)) {
        Write-Host "  ✗ ERROR: JAR not found at $jarPath" -ForegroundColor Red
        Write-Host "  Run: cd $workingDir && .\gradlew build -x test" -ForegroundColor Yellow
        continue
    }
    
    # Start the service
    $cmd = "cd `"$workingDir`"; java -jar `"$jarPath`""
    Start-Process -FilePath powershell -ArgumentList "-NoExit", "-Command", $cmd -WindowStyle Normal
    
    Write-Host "  ✓ Window opened for $serviceName" -ForegroundColor Green
    
    if ($Sequential) {
        Write-Host "  Waiting 5 seconds before starting next service..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    } else {
        Write-Host "  Waiting 2 seconds before starting next service..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
}

Write-Host ""
Write-Host "=== All Services Started ===" -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Discovery Server: http://localhost:8761" -ForegroundColor White
Write-Host "  Config Server:    http://localhost:8888" -ForegroundColor White
Write-Host "  API Gateway:      http://localhost:8080" -ForegroundColor White
Write-Host "  Course Service:   http://localhost:8081" -ForegroundColor White
Write-Host "  Enrollment Svc:   http://localhost:8082" -ForegroundColor White
Write-Host ""
Write-Host "Test the system:" -ForegroundColor Cyan
Write-Host "  curl http://localhost:8761/eureka/apps" -ForegroundColor Gray
Write-Host "  curl http://localhost:8080/api/courses" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTE: Allow 10-15 seconds for all services to start and register with Eureka" -ForegroundColor Yellow
