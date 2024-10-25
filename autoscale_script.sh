#!/bin/bash

# Set variables
SERVICE_NAME="cloud_project"  # Replace with your Docker service name
MAX_REPLICAS=5
MIN_REPLICAS=1
THRESHOLD=128  # Scale up if memory usage exceeds 80%

# Get current memory usage from Prometheus
MEMORY_USAGE=$(curl -s "http://prometheus:9090/api/v1/query?query=avg_over_time(container_memory_usage_bytes{container_name='$SERVICE_NAME'}[5m])" | jq '.data.result[0].value[1] | tonumber')

# Convert bytes to megabytes
MEMORY_USAGE_MB=$(echo "$MEMORY_USAGE / 1024 / 1024" | bc)

# Get current replicas count
CURRENT_REPLICAS=$(docker-compose ps --filter "name=$SERVICE_NAME" --format "{{.Name}}" | wc -l)

# Autoscale logic
if (( $(echo "$MEMORY_USAGE_MB > $THRESHOLD" | bc -l) )); then
    if [ $CURRENT_REPLICAS -lt $MAX_REPLICAS ]; then
        echo "Scaling up $SERVICE_NAME from $CURRENT_REPLICAS to $((CURRENT_REPLICAS + 1)) replicas."
        docker-compose up --scale $SERVICE_NAME=$((CURRENT_REPLICAS + 1)) -d
    else
        echo "Max replicas reached. Current: $CURRENT_REPLICAS."
    fi
elif (( $(echo "$MEMORY_USAGE_MB < ($THRESHOLD / 2)" | bc -l) )); then
    if [ $CURRENT_REPLICAS -gt $MIN_REPLICAS ]; then
        echo "Scaling down $SERVICE_NAME from $CURRENT_REPLICAS to $((CURRENT_REPLICAS - 1)) replicas."
        docker-compose up --scale $SERVICE_NAME=$((CURRENT_REPLICAS - 1)) -d
    else
        echo "Min replicas reached. Current: $CURRENT_REPLICAS."
    fi
else
    echo "No scaling action needed. Current memory usage: $MEMORY_USAGE_MB MB."
fi
