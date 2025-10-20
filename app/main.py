from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="High-Availability FastAPI Microservice")

# Prometheus metrics
REQUEST_COUNT = Counter(
    'fastapi_requests_total',
    'Total request count',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'fastapi_request_duration_seconds',
    'Request duration in seconds',
    ['method', 'endpoint']
)

@app.get("/")
def read_root():
    """Root endpoint - health check"""
    REQUEST_COUNT.labels(method='GET', endpoint='/', status='200').inc()
    logger.info("Root endpoint accessed")
    return {
        "message": "Hello from FastAPI microservice",
        "status": "healthy",
        "service": "high-availability-fastapi"
    }

@app.get("/health")
def health_check():
    """Kubernetes health check endpoint"""
    REQUEST_COUNT.labels(method='GET', endpoint='/health', status='200').inc()
    return {"status": "healthy", "uptime": "ok"}

@app.get("/compute")
def compute_heavy():
    """Simulate compute-intensive operation"""
    start_time = time.time()
    
    # Simulate computation
    time.sleep(0.5)
    
    duration = time.time() - start_time
    REQUEST_DURATION.labels(method='GET', endpoint='/compute').observe(duration)
    REQUEST_COUNT.labels(method='GET', endpoint='/compute', status='200').inc()
    
    logger.info(f"Compute endpoint processed in {duration:.3f}s")
    return {
        "result": "Computation complete",
        "duration_seconds": duration,
        "status": "success"
    }

@app.get("/metrics")
def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/info")
def get_info():
    """Service information endpoint"""
    REQUEST_COUNT.labels(method='GET', endpoint='/info', status='200').inc()
    return {
        "service": "high-availability-fastapi",
        "version": "1.0.0",
        "description": "Production-ready FastAPI microservice with HA",
        "endpoints": ["/", "/health", "/compute", "/metrics", "/info"]
    }
