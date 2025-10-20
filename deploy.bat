@echo off
REM Deployment script for CMD - High-Availability FastAPI Microservice

if "%~1"=="" (
    set COMMAND=help
) else (
    set COMMAND=%~1
)

if /i "%COMMAND%"=="full" goto full
if /i "%COMMAND%"=="build" goto build
if /i "%COMMAND%"=="deploy" goto deploy
if /i "%COMMAND%"=="status" goto status
if /i "%COMMAND%"=="cleanup" goto cleanup
if /i "%COMMAND%"=="help" goto help
goto help

:full
echo.
echo =========================================
echo Building Docker Image
echo =========================================
echo.
docker build -t fastapi-service:latest .
if errorlevel 1 (
    echo Docker build failed!
    exit /b 1
)
echo Docker image built successfully
echo.
echo =========================================
echo Deploying to Kubernetes
echo =========================================
echo.
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/prometheus.yaml
kubectl apply -f k8s/grafana.yaml
echo.
echo All components deployed successfully
echo.
echo =========================================
echo Waiting for Pods to be Ready
echo =========================================
echo.
timeout /t 10 /nobreak
kubectl get pods
echo.
echo =========================================
echo Deployment Status
echo =========================================
echo.
kubectl get pods
echo.
kubectl get services
echo.
kubectl get hpa
echo.
echo =========================================
echo Port Forwarding Commands
echo =========================================
echo.
echo Run these in separate CMD/PowerShell windows:
echo.
echo 1. FastAPI (via NGINX):
echo    kubectl port-forward svc/nginx-service 8080:80
echo.
echo 2. Prometheus:
echo    kubectl port-forward svc/prometheus 9090:9090
echo.
echo 3. Grafana:
echo    kubectl port-forward svc/grafana 3000:3000
echo.
goto end

:build
echo Building Docker Image...
docker build -t fastapi-service:latest .
if errorlevel 1 (
    echo Docker build failed!
    exit /b 1
)
echo Docker image built successfully
goto end

:deploy
echo Deploying to Kubernetes...
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/prometheus.yaml
kubectl apply -f k8s/grafana.yaml
echo Deployment complete
timeout /t 5 /nobreak
kubectl get pods
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

:cleanup
echo Cleaning up Kubernetes resources...
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/service.yaml --ignore-not-found=true
kubectl delete -f k8s/hpa.yaml --ignore-not-found=true
kubectl delete -f k8s/nginx-configmap.yaml --ignore-not-found=true
kubectl delete -f k8s/nginx-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/prometheus.yaml --ignore-not-found=true
kubectl delete -f k8s/grafana.yaml --ignore-not-found=true
echo Cleanup complete
goto end

:help
echo.
echo Usage: deploy.bat [command]
echo.
echo Commands:
echo   build     - Build Docker image only
echo   deploy    - Deploy to Kubernetes
echo   full      - Build + Deploy + Status
echo   status    - Show deployment status
echo   cleanup   - Delete all resources
echo   help      - Show this help
echo.
echo Examples:
echo   deploy.bat full
echo   deploy.bat status
echo   deploy.bat cleanup
echo.
goto end

:end
