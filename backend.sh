#!/bin/bash

FILTER_NAME="tag:Name"
FILTER_VALUE="BACKEND"

# Get the instance ID of the backend instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=$FILTER_NAME,Values=$FILTER_VALUE" --query 'Reservations[0].Instances[0].InstanceId' --output text)


FRONTEND_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull amankumars20/backend_image_app:latest

sudo docker run -d -p 8000:8000 -e FRONTEND_URL=http://${FRONTEND_PUBLIC_IP}:3000 amankumars20/backend_image_app:latest