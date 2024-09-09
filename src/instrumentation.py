# instrumentation.py
from time import time
from monitor_init import init_metrics, init_tracing
from fastapi import FastAPI, Request
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

trace_provider = init_tracing()

def instrumentation(app: FastAPI, additional_atrributes):
    _, meter = init_metrics(additional_attributes = additional_atrributes)
    
    request_counter = meter.create_counter(
        "http_requests_total",
        description="Total number of HTTP requests",
        unit="1"
    )

    request_duration_histogram = meter.create_histogram(
        "http_request_duration_seconds",
        description="HTTP request duration in seconds",
        unit="s"
    )

    # Middleware to track request counts and duration
    @app.middleware("http")
    async def add_metrics_middleware(request: Request, call_next):
        start = time()
        response = await call_next(request)
        duration = time() - start

        # Update metrics
        request_counter.add(1, {"method": request.method, "endpoint": request.url.path, "status_code": response.status_code})
        request_duration_histogram.record(duration, {"method": request.method, "endpoint": request.url.path, "status_code": response.status_code})

        return response