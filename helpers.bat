@echo off
REM Helper Script for CMD - High-Availability FastAPI Microservice

if "%~1"=="" (
    goto help
)

set COMMAND=%~1

if /i "%COMMAND%"=="logs" goto logs
if /i "%COMMAND%"=="watch" goto watch
if /i "%COMMAND%"=="restart" goto restart
if /i "%COMMAND%"=="scale" goto scale
if /i "%COMMAND%"=="metrics" goto metrics
if /i "%COMMAND%"=="grafana" goto grafana
if /i "%COMMAND%"=="api" goto api
if /i "%COMMAND%"=="hpa" goto hpa
if /i "%COMMAND%"=="describe" goto describe
if /i "%COMMAND%"=="events" goto events
if /i "%COMMAND%"=="top" goto top
if /i "%COMMAND%"=="status" goto status
if /i "%COMMAND%"=="ports" goto ports
if /i "%COMMAND%"=="test-quick" goto test-quick
if /i "%COMMAND%"=="test-medium" goto test-medium
if /i "%COMMAND%"=="test-heavy" goto test-heavy
goto help

:logs
echo Tailing logs from all FastAPI pods...
kubectl logs -l app=fastapi --tail=100 -f
goto end

:watch
echo Watching pod status (Ctrl+C to exit)...
kubectl get pods -w
goto end

:restart
echo Restarting FastAPI deployment...
kubectl rollout restart deployment/fastapi-deployment
echo Waiting for rollout to complete...
kubectl rollout status deployment/fastapi-deployment
echo Deployment restarted successfully
goto end

:scale
if "%~2"=="" (
    echo Usage: helpers.bat scale [number]
    echo Example: helpers.bat scale 6
    goto end
)
echo Scaling to %~2 replicas...
kubectl scale deployment/fastapi-deployment --replicas=%~2
timeout /t 2 /nobreak >nul
kubectl get pods -l app=fastapi
goto end

:metrics
echo Opening Prometheus...
echo Make sure port-forward is running: kubectl port-forward svc/prometheus 9090:9090
start http://localhost:9090
goto end

:grafana
echo Opening Grafana...
echo Make sure port-forward is running: kubectl port-forward svc/grafana 3000:3000
echo Login: admin / admin
start http://localhost:3000
goto end

:api
echo Opening FastAPI docs...
echo Make sure port-forward is running: kubectl port-forward svc/nginx-service 8080:80
start http://localhost:8080/docs
goto end

:hpa
echo Watching HPA status (Ctrl+C to exit)...
kubectl get hpa -w
goto end

:describe
echo Describing FastAPI deployment...
kubectl describe deployment fastapi-deployment
goto end

:events
echo Recent Kubernetes events...
kubectl get events --sort-by=.lastTimestamp
goto end

:top
echo Resource usage...
kubectl top pods -l app=fastapi
goto end

:status
echo.
echo === DEPLOYMENTS ===
kubectl get deployments
echo.
echo === PODS ===
kubectl get pods
echo.
echo === SERVICES ===
kubectl get services
echo.
echo === HPA ===
kubectl get hpa
goto end

:ports
echo.
echo Port Forwarding Commands
echo ========================================
echo.
echo Open these in SEPARATE CMD windows:
echo.
echo 1. FastAPI (via NGINX):
echo    kubectl port-forward svc/nginx-service 8080:80
echo    Access: http://localhost:8080
echo.
echo 2. Prometheus:
echo    kubectl port-forward svc/prometheus 9090:9090
echo    Access: http://localhost:9090
echo.
echo 3. Grafana:
echo    kubectl port-forward svc/grafana 3000:3000
echo    Access: http://localhost:3000 (admin/admin)
echo.
goto end

:test-quick
echo Running quick load test (1K users, 1 min)...
echo Make sure port-forward is running: kubectl port-forward svc/nginx-service 8080:80
cd tests
locust -f load_test.py --host=http://localhost:8080 --users 1000 --spawn-rate 50 --run-time 1m --headless
cd ..
goto end

:test-medium
echo Running medium load test (5K users, 3 min)...
echo Make sure port-forward is running: kubectl port-forward svc/nginx-service 8080:80
cd tests
locust -f load_test.py --host=http://localhost:8080 --users 5000 --spawn-rate 100 --run-time 3m --headless --html report-medium.html
cd ..
echo Report saved to tests\report-medium.html
goto end

:test-heavy
echo Running heavy load test (10K users, 5 min)...
echo Make sure port-forward is running: kubectl port-forward svc/nginx-service 8080:80
cd tests
locust -f load_test.py --host=http://localhost:8080 --users 10000 --spawn-rate 200 --run-time 5m --headless --html report-heavy.html
cd ..
echo Report saved to tests\report-heavy.html
goto end

:help
echo.
echo ============================================================
echo       FastAPI High-Availability Helper Commands
echo ============================================================
echo.
echo DEPLOYMENT:
echo   logs          - Tail logs from all FastAPI pods
echo   watch         - Watch pod status in real-time
echo   restart       - Restart FastAPI deployment
echo   scale [N]     - Scale to N replicas (e.g., helpers.bat scale 6)
echo.
echo MONITORING:
echo   metrics       - Open Prometheus in browser
echo   grafana       - Open Grafana dashboard in browser
echo   api           - Open FastAPI docs in browser
echo   hpa           - Watch HPA status in real-time
echo.
echo DEBUGGING:
echo   describe      - Describe FastAPI deployment
echo   events        - Show recent Kubernetes events
echo   top           - Show resource usage of pods
echo.
echo TESTING:
echo   test-quick    - Quick load test (1K users, 1 min)
echo   test-medium   - Medium load test (5K users, 3 min)
echo   test-heavy    - Heavy load test (10K users, 5 min)
echo.
echo UTILITIES:
echo   ports         - Show port forwarding commands
echo   status        - Show comprehensive status
echo.
echo EXAMPLES:
echo   helpers.bat logs
echo   helpers.bat scale 8
echo   helpers.bat test-medium
echo   helpers.bat status
echo.
goto end

:end
