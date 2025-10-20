from locust import HttpUser, task, between, events
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class FastAPIUser(HttpUser):
    """
    Load test user for FastAPI microservice
    Simulates realistic user behavior with different endpoint usage patterns
    """
    
    # Wait between 1-2 seconds between tasks (simulates real user behavior)
    wait_time = between(1, 2)
    
    @task(10)
    def root_endpoint(self):
        """Test root endpoint (highest frequency)"""
        with self.client.get("/", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed with status code: {response.status_code}")
    
    @task(5)
    def health_check(self):
        """Test health endpoint (medium frequency)"""
        with self.client.get("/health", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Health check failed: {response.status_code}")
    
    @task(3)
    def compute_endpoint(self):
        """Test compute endpoint (lower frequency due to being resource-intensive)"""
        with self.client.get("/compute", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Compute failed: {response.status_code}")
    
    @task(2)
    def info_endpoint(self):
        """Test info endpoint"""
        with self.client.get("/info", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Info failed: {response.status_code}")


@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Called when load test starts"""
    logger.info("🚀 Starting load test for FastAPI High-Availability service")
    logger.info(f"Target host: {environment.host}")


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Called when load test stops - print summary"""
    logger.info("✅ Load test completed")
    
    stats = environment.stats
    logger.info(f"\n{'='*60}")
    logger.info("LOAD TEST SUMMARY")
    logger.info(f"{'='*60}")
    logger.info(f"Total requests: {stats.total.num_requests}")
    logger.info(f"Total failures: {stats.total.num_failures}")
    logger.info(f"Average response time: {stats.total.avg_response_time:.2f}ms")
    logger.info(f"Min response time: {stats.total.min_response_time:.2f}ms")
    logger.info(f"Max response time: {stats.total.max_response_time:.2f}ms")
    logger.info(f"Requests/sec: {stats.total.total_rps:.2f}")
    logger.info(f"Failure rate: {(stats.total.fail_ratio * 100):.2f}%")
    logger.info(f"{'='*60}\n")
