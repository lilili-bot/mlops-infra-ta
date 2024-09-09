# Local test with minikube.

.PHONY: all setup-collector deploy-collector expose-collector run-fastapi clean

# Variables
MINIKUBE_IP := $(shell minikube ip)
OTEL_NAMESPACE := otel-col
OTEL_COLLECTOR_NAME := otel-collector

# URLs obtained from the minikube service output
OTLP_GRPC_PORT ?= 4317  # Default gRPC port for OTLP
OTLP_HTTP_PORT ?= 4318  # Default HTTP port for OTLP

# Default target
all: setup-collector deploy-collector expose-collector run-fastapi

# Step 1: Create namespace and set up Helm repo
setup-collector:
	kubectl apply -f otel-collector/otel-collector-namespace.yaml
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
	helm repo update

# Step 2: Deploy OpenTelemetry Collector
deploy-collector:
	helm upgrade --install $(OTEL_COLLECTOR_NAME) open-telemetry/opentelemetry-collector \
		--namespace $(OTEL_NAMESPACE) \
		--create-namespace \
		--values otel-collector/values.yaml \
		--values otel-collector/values.dev.yaml

# Step 3: Create Service
create-service:
	kubectl apply -f otel-collector/service.yaml

# Step 4 Expose OpenTelemetry Collector via Minikube
expose-collector:
	@echo "Waiting 30 seconds for the OpenTelemetry Collector service to be available..."
	@echo "Exposing OpenTelemetry Collector via Minikube Tunnel. Please ensure 'minikube tunnel' runs in another terminal."
	@echo "Press [ENTER] once 'minikube tunnel' is running."
	read dummy
	@echo "Capturing Minikube service URL..."
	minikube service $(OTEL_COLLECTOR_NAME) -n $(OTEL_NAMESPACE) --url > .tunnel_output.txt &
	sleep 3
	grep http .tunnel_output.txt | head -n 1 > .otlp_endpoint
	@echo "OpenTelemetry OTLP Endpoint: $$(cat .otlp_endpoint)"
	rm -f .tunnel_output.txt

# Step 4: Run FastAPI locally
run-fastapi:
	@echo "Running FastAPI with OpenTelemetry Collector configuration..."
	# Read the OTLP_ENDPOINT from the file and run FastAPI
	cd app && OTEL_EXPORTER_OTLP_ENDPOINT=$(shell cat .otlp_endpoint) uvicorn main:app --reload

# Clean up resources
clean:
	helm uninstall $(OTEL_COLLECTOR_NAME) --namespace $(OTEL_NAMESPACE)
	# delete all the resources within the namespace.
	kubectl delete namespace $(OTEL_NAMESPACE)
	rm -f .otlp_endpoint
	kubectl get all --all-namespaces | grep otel-col

# useful commands
# Test api 
# curl -X POST "http://localhost:8000/items/" -H "Content-Type: application/json" -d '{"name": "Item1", "description": "A test item", "price": 10.5, "tax": 1.5}'


# To verify the connectivity of API and otel-collector. 
# POD_NAME=$(kubectl get pods -n otel-col -l app.kubernetes.io/instance=otel-collector,app.kubernetes.io/name=opentelemetry-collector,component=agent-collector -o jsonpath="{.items[0].metadata.name}")
# kubectl logs $POD_NAME -n otel-col
# command to create a secrate for image pulling if needed.
# kubectl create secret generic gcr-json-key \    
#   --from-file=.dockerconfigjson=$HOME/.docker/config.json \
#   --type=kubernetes.io/dockerconfigjson