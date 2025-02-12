#!/bin/bash

INSTANCE_ID="i-08f295f2621586927"
DOCKER_COMPOSE_PATH="/mnt/c/Users/DELL/Hello_world/CloudProject/docker-compose.yml"
EC2_PUBLIC_IP="34.203.224.114"
KEY_PAIR_PATH="C:/Users/DELL/Downloads/Work.pem"  # Keep the Windows-style path for use in the SSH command

# Check the current hour and minute without leading zeros
current_hour=$(date +"%H" | sed 's/^0*//')
current_minute=$(date +"%M" | sed 's/^0*//')

# Display debug info
echo "Debug: Current hour is $current_hour and current minute is $current_minute"

# Start/Stop EC2 instance based on time
if [[ "$current_hour" -eq 11 ]]; then
    echo "Shutting down the EC2 instance..."
    aws ec2 stop-instances --instance-ids "$INSTANCE_ID"

elif [[ "$current_hour" -eq 16 ]]; then
    echo "Starting the EC2 instance..."
    aws ec2 start-instances --instance-ids "$INSTANCE_ID"

    # Wait for the instance to start
    echo "Waiting for instance to be in running state..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    echo "Instance is running, starting Docker containers..."

    # Make sure the key permissions are set correctly
    chmod 600 "$KEY_PAIR_PATH"
    echo "Permission granted for $KEY_PAIR_PATH"

    # Run Docker Compose on EC2 using SSH from WSL
    echo "Connecting to EC2 instance via SSH..."
    ssh -i "$KEY_PAIR_PATH" -o StrictHostKeyChecking=no ubuntu@$EC2_PUBLIC_IP "docker compose -f \"$DOCKER_COMPOSE_PATH\" up -d"
else
    echo "Debug: Current hour ($current_hour) and ($current_minute) did not match any conditions."
fi
