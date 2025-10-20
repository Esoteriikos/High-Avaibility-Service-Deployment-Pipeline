# Load Testing Scripts

## Running Locust Load Tests

### Installation
```bash
pip install -r requirements.txt
```

### Local Testing (Development)
```bash
# Test against local Docker container
locust -f load_test.py --host=http://localhost:8000
```

### Kubernetes Testing
```bash
# Port-forward to NGINX load balancer
kubectl port-forward svc/nginx-service 8080:80

# Run load test
locust -f load_test.py --host=http://localhost:8080
```

### Headless Mode (CLI)
For automated testing without the web UI:

```bash
# 10,000 users, spawn rate of 100 users/sec, run for 5 minutes
locust -f load_test.py --host=http://localhost:8080 \
  --users 10000 \
  --spawn-rate 100 \
  --run-time 5m \
  --headless \
  --html report.html
```

### Web UI Mode
```bash
locust -f load_test.py --host=http://localhost:8080
```
Then open http://localhost:8089 in your browser.

## Test Scenarios

### Scenario 1: Baseline (1K users)
```bash
locust -f load_test.py --host=http://localhost:8080 \
  --users 1000 --spawn-rate 50 --run-time 3m --headless
```

### Scenario 2: Medium Load (5K users)
```bash
locust -f load_test.py --host=http://localhost:8080 \
  --users 5000 --spawn-rate 100 --run-time 5m --headless
```

### Scenario 3: High Load (10K+ users)
```bash
locust -f load_test.py --host=http://localhost:8080 \
  --users 10000 --spawn-rate 200 --run-time 10m --headless
```

### Scenario 4: Stress Test (20K users)
```bash
locust -f load_test.py --host=http://localhost:8080 \
  --users 20000 --spawn-rate 300 --run-time 10m --headless
```

## Monitoring During Tests

While running load tests, monitor:
- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus Metrics**: http://localhost:9090
- **Kubernetes Pods**: `kubectl get pods -w`
- **HPA Status**: `kubectl get hpa -w`

## Expected Results

For **10K concurrent users**:
- Average latency: < 200ms
- P95 latency: < 500ms
- P99 latency: < 1000ms
- Success rate: > 99.9%
- RPS: > 5000 requests/second

## Distributed Load Testing

For very high loads, run Locust in distributed mode:

**Master node:**
```bash
locust -f load_test.py --master --host=http://localhost:8080
```

**Worker nodes (run multiple terminals):**
```bash
locust -f load_test.py --worker --master-host=localhost
locust -f load_test.py --worker --master-host=localhost
locust -f load_test.py --worker --master-host=localhost
```
