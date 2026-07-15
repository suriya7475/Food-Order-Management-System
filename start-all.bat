@echo off
setlocal

:: ===================================================
:: FoodFlow Microservices - Master Startup Script
:: ===================================================

set "ROOT=c:\Users\acer\Downloads\Hotel management system"
set "TOOLS=%ROOT%\tools"
set "NODE=%TOOLS%\node-v20.11.1-win-x64\node.exe"
set "NPM=%TOOLS%\node-v20.11.1-win-x64\npm.cmd"
set "MVN=%TOOLS%\apache-maven-3.9.6\bin\mvn.cmd"
set "JAVA=C:\Program Files\Java\jdk-21.0.10\bin\java.exe"
set "ACTIVEMQ=%TOOLS%\apache-activemq-5.18.3\bin\win64\activemq.bat"
set "MYSQL=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe"
set "DBDATA=%ROOT%\db_data"

echo.
echo  ================================================
echo    FoodFlow - Starting All Services
echo  ================================================
echo.

:: 1. Start MySQL (local instance, port 3307)
echo [1/6] Starting MySQL on port 3307...
start "MySQL-3307" cmd /c ""%MYSQL%" --datadir="%DBDATA%" --port=3307 --console"
timeout /t 4 /nobreak > nul
echo     MySQL started.

:: 2. Start ActiveMQ (port 61616)
echo [2/6] Starting ActiveMQ on port 61616...
start "ActiveMQ" cmd /c ""%ACTIVEMQ%""
timeout /t 6 /nobreak > nul
echo     ActiveMQ started.

:: 3. Build and Start Payment Service (port 8082)
echo [3/6] Starting Payment Service on port 8082...
start "PaymentService" cmd /c ""%MVN%" -f "%ROOT%\backend\payment-service\pom.xml" spring-boot:run"
timeout /t 3 /nobreak > nul

:: 4. Build and Start Kitchen Service (port 8083)
echo [4/6] Starting Kitchen Service on port 8083...
start "KitchenService" cmd /c ""%MVN%" -f "%ROOT%\backend\kitchen-service\pom.xml" spring-boot:run"
timeout /t 3 /nobreak > nul

:: 5. Build and Start Delivery Service (port 8084)
echo [5/6] Starting Delivery Service on port 8084...
start "DeliveryService" cmd /c ""%MVN%" -f "%ROOT%\backend\delivery-service\pom.xml" spring-boot:run"
timeout /t 3 /nobreak > nul

:: 6. Build and Start Order Service (port 8081, with Camunda)
echo [6/6] Starting Order Service on port 8081 (with Camunda BPMN)...
start "OrderService" cmd /c ""%MVN%" -f "%ROOT%\backend\order-service\pom.xml" spring-boot:run"
timeout /t 5 /nobreak > nul

echo.
echo  ================================================
echo    Backend services started! (builds take ~90s)
echo  ================================================
echo.
echo  Waiting 90 seconds for Spring Boot to compile...
timeout /t 90 /nobreak

:: 7. Install npm deps and Start React Frontend
echo.
echo [Frontend] Installing npm packages...
cd /d "%ROOT%\frontend"
call "%NPM%" install
echo [Frontend] Starting React UI on http://localhost:5173 ...
start "ReactFrontend" cmd /c ""%NPM%" run dev"
timeout /t 5 /nobreak > nul

echo.
echo  ================================================
echo    ALL SERVICES RUNNING!
echo  ================================================
echo.
echo    MySQL        : localhost:3307
echo    ActiveMQ     : localhost:61616
echo    Order Svc    : http://localhost:8081
echo    Payment Svc  : http://localhost:8082
echo    Kitchen Svc  : http://localhost:8083
echo    Delivery Svc : http://localhost:8084
echo    Camunda UI   : http://localhost:8081/camunda/app/
echo    React UI     : http://localhost:5173
echo.
echo  Opening browser...
timeout /t 3 /nobreak > nul
start "" http://localhost:5173

pause
