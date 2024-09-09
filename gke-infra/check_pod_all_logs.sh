#!/bin/bash

# Set your namespace
NAMESPACE=otel-col

# Iterate over each OTel collector pod
for pod in $(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=gsd-otel-collector,app.kubernetes.io/name=opentelemetry-collector -o jsonpath="{.items[*].metadata.name}"); do
  echo "Checking logs for pod $pod"
  # Fetch and display the last 100 lines of logs, then filter for specific log entries
  kubectl logs $pod -n $NAMESPACE | tail -n 100 | grep --color -i -E 'span|metrics|otel|error'
  echo "---------------------------------------------"
done
