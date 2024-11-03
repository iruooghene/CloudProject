#!/bin/bash
set -e

SERVICE_NAME="app"
MEMORY_LIMIT_MB=128
SCALE_UP_THRESHOLD=123
SCALE_DOWN_THRESHOLD=100
MAX_REPLICAS=5
MIN_REPLICAS=1

export COMPOSE_HTTP_TIMEOUT=300
cd "$(dirname "$0")" || exit 1
scaling_in_progress=false

# Function to get memory usage of the service
get_memory_usage() {
  docker stats --no-stream --format "{{.MemUsage}}" $(docker-compose ps -q $SERVICE_NAME) | awk -F '[ /]+' '{print $1 + 0}'
}

# Function to get the current replica count of the service
get_current_scale() {
  docker-compose ps -q $SERVICE_NAME | wc -l
}

# Scale up the service
scale_service() {
  current_scale=$(get_current_scale)
  if [ "$current_scale" -lt "$MAX_REPLICAS" ]; then
    echo "[$(date)] Scaling $SERVICE_NAME to $((current_scale + 1)) replicas"
    docker-compose up --scale "$SERVICE_NAME=$((current_scale + 1))" -d && scaling_in_progress=true
  else
    echo "[$(date)] Max replicas reached ($MAX_REPLICAS)."
  fi
}

# Scale down the service
scale_down_service() {
  current_scale=$(get_current_scale)
  if [ "$current_scale" -gt "$MIN_REPLICAS" ]; then
    echo "[$(date)] Scaling $SERVICE_NAME down to $((current_scale - 1)) replicas"
    docker-compose up --scale "$SERVICE_NAME=$((current_scale - 1))" -d
    docker rm -f $(docker-compose ps -q $SERVICE_NAME | tail -n 1) 2>/dev/null || echo "Container removal skipped."
  else
    echo "[$(date)] Only one replica running. Cannot scale down."
  fi
}

# Send load test requests to the application
send_requests() {
  local url="http://localhost:8080/fibonacci/9000"
  echo "[$(date)] Sending requests to $url..."
  for _ in {1..9000}; do curl -s "$url" & done
  wait
  echo "[$(date)] Requests sent."
}

# Handle script termination
trap "echo 'Stopping script...'; exit" SIGINT SIGTERM

# Main loop for monitoring and scaling
while true; do
  memory_usage=$(get_memory_usage)
  current_scale=$(get_current_scale)
  echo "[$(date)] Memory: $memory_usage MB, Replicas: $current_scale"

  if [ "$memory_usage" -ge "$SCALE_UP_THRESHOLD" ] && ! $scaling_in_progress; then
    scale_service
  elif [ "$memory_usage" -lt "$SCALE_DOWN_THRESHOLD" ] && [ "$current_scale" -gt "$MIN_REPLICAS" ]; then
    scale_down_service
  else
    echo "[$(date)] Memory usage within limits."
  fi

  # Wait for stability after scaling
  if $scaling_in_progress; then
    sleep 60
    scaling_in_progress=false
  else
    sleep 30
  fi
done
