# init_monitoring.py

import os
from opentelemetry import trace, metrics
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider 
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.metrics.export import ConsoleMetricExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

default_resource_attributes = {
    "service.name": "fast-api"
}
trace.set_tracer_provider(TracerProvider(resource=Resource(attributes=default_resource_attributes)))
tracer = trace.get_tracer(__name__)

def set_resource_attributes(additional_attributes=None):
    default_resource_attributes = {
    "service.name": "larmorne"
    }
    attributes = {}
    if additional_attributes is None:
        attributes = default_resource_attributes
    else:
        # Merge default attributes with additional attributes
        attributes = {**default_resource_attributes, **additional_attributes}
    resource = Resource(attributes=attributes)
    return resource

def get_otlpendpoint():
    otlp_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317")
    return otlp_endpoint

def init_tracing(additional_attributes=None):
    
    # Set up Tracer Provider
    # tracer_provider = TracerProvider()
    # trace.set_tracer_provider(tracer_provider)

    # # Setup OTLP Exporter for Spans
    # otlp_spans_exporter = OTLPSpanExporter(endpoint="localhost:4317", insecure=True)
    # span_processor = BatchSpanProcessor(otlp_spans_exporter)
    # trace.get_tracer_provider().add_span_processor(span_processor)

    # # Also add Console Exporter for debugging purposes
    # console_span_exporter = ConsoleSpanExporter()
    # tracer_provider.add_span_processor(BatchSpanProcessor(console_span_exporter))
    resource = set_resource_attributes(additional_attributes=additional_attributes)
    trace.set_tracer_provider(TracerProvider(resource=resource))
    trace_provider = trace.get_tracer_provider()

    # Setup OTLP exporter (sending to the OpenTelemetry Collector)
    otlp_endpoint= get_otlpendpoint()
    
    # Set up the OTLP exporter for traces
    otlp_trace_exporter = OTLPSpanExporter(endpoint=otlp_endpoint, insecure=True)
    span_processor = BatchSpanProcessor(otlp_trace_exporter)
    trace_provider.add_span_processor(span_processor)

    console_span_exporter = ConsoleSpanExporter()
    trace_provider.add_span_processor(BatchSpanProcessor(console_span_exporter))

    return trace_provider

def init_metrics(additional_attributes=None):
    resource = set_resource_attributes(additional_attributes=additional_attributes)
    otlp_endpoint = get_otlpendpoint()
    # Create an OTLP exporter
    otlp_metric_exporter = OTLPMetricExporter(endpoint=otlp_endpoint, insecure=True)
    
    # Create a PeriodicExportingMetricReader with the OTLP exporter
    metric_reader_remote = PeriodicExportingMetricReader(exporter=otlp_metric_exporter, export_interval_millis=60000)

    # For debugging metrics
    consol_metric_reader = PeriodicExportingMetricReader(ConsoleMetricExporter(), export_interval_millis=60000)
     # Set up the meter provider
    meter_provider = MeterProvider(
        resource=resource,
        metric_readers=[metric_reader_remote, consol_metric_reader]
    )
    metrics.set_meter_provider(meter_provider)
    meter = metrics.get_meter(__name__)

    return metrics, meter