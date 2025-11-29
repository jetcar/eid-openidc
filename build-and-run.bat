@echo off
REM Build and Run All Projects Script
REM This script cleans, builds, and runs all three Java projects

echo ========================================
echo Building and Running EID OIDC Projects
echo ========================================
echo.

REM Step 1: Clean and build eid-mock
echo [1/3] Building eid-mock...
cd /d "%~dp0eid-mock"
if exist "target" (
    echo   Cleaning eid-mock\target...
    rmdir /s /q "target"
)
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERROR: eid-mock build failed!
    cd /d "%~dp0"
    pause
    exit /b 1
)
echo   eid-mock built successfully.
echo.

REM Step 2: Clean and build eid-oidc-provider
echo [2/3] Building eid-oidc-provider...
cd /d "%~dp0eid-oidc-provider"
if exist "target" (
    echo   Cleaning eid-oidc-provider\target...
    rmdir /s /q "target"
)
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERROR: eid-oidc-provider build failed!
    cd /d "%~dp0"
    pause
    exit /b 1
)
echo   eid-oidc-provider built successfully.
echo.

REM Step 3: Clean and build oidc-test
echo [3/3] Building oidc-test...
cd /d "%~dp0oidc-test"
if exist "target" (
    echo   Cleaning oidc-test\target...
    rmdir /s /q "target"
)
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERROR: oidc-test build failed!
    cd /d "%~dp0"
    pause
    exit /b 1
)
echo   oidc-test built successfully.
echo.

REM Return to root directory
cd /d "%~dp0"

echo All builds completed successfully!
echo.

REM Step 4: Run all projects
echo Starting all projects...
echo.

REM Check if JAR files exist
if not exist "eid-mock\target\eid-mock-0.0.1-SNAPSHOT.jar" (
    echo ERROR: eid-mock JAR not found!
    pause
    exit /b 1
)
if not exist "eid-oidc-provider\target\eid-oidc-provider-1.0-SNAPSHOT.jar" (
    echo ERROR: eid-oidc-provider JAR not found!
    pause
    exit /b 1
)
if not exist "oidc-test\target\oidc-test-1.0-SNAPSHOT.jar" (
    echo ERROR: oidc-test JAR not found!
    pause
    exit /b 1
)

REM Start eid-mock
echo   Starting eid-mock on port 8083...
start "EID Mock" cmd /k "cd /d %~dp0 && java -jar eid-mock\target\eid-mock-0.0.1-SNAPSHOT.jar"
timeout /t 2 /nobreak >nul

REM Start eid-oidc-provider
echo   Starting eid-oidc-provider on port 8443...
start "EID OIDC Provider" cmd /k "cd /d %~dp0 && java -jar eid-oidc-provider\target\eid-oidc-provider-1.0-SNAPSHOT.jar"
timeout /t 2 /nobreak >nul

REM Start oidc-test
echo   Starting oidc-test on port 8082...
start "OIDC Test Client" cmd /k "cd /d %~dp0 && java -jar oidc-test\target\oidc-test-1.0-SNAPSHOT.jar"

echo.
echo ========================================
echo All projects started!
echo ========================================
echo.
echo Access points:
echo   - EID Mock:           https://localhost:8083
echo   - EID OIDC Provider:  https://localhost:8443
echo   - OIDC Test Client:   https://localhost:8082
echo   - Swagger UI:         https://localhost:8443/swagger-ui.html
echo.
echo Each project is running in a separate window.
echo Close the windows to stop the services.
echo.
pause
