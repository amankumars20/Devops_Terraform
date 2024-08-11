#!/bin/bash

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update


aws configure set aws_access_key_id "dfgdf" --profile user2 && aws configure set aws_secret_access_key "dfg" --profile user2 && aws configure set region "eu-north-1" --profile user2 && aws configure set output "text" --profile user2
# Set the filter criteria for the backend instance

FILTER_NAME="tag:Name"
FILTER_VALUE="FRONTEND"

# Get the instance ID of the backend instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=$FILTER_NAME,Values=$FILTER_VALUE" --query 'Reservations[0].Instances[0].InstanceId' --output text)

# Get the public IP address of the backend instance
BACKEND_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)


# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker


sudo docker pull amankumars20/frontend_image_app:latest

sudo docker run -d -p 3000:3000 -e VITE_BACKEND_URL=http://${BACKEND_PUBLIC_IP}:8000 amankumars20/frontend_image_app:latest