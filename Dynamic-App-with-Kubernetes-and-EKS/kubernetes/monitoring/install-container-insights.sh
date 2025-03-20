#!/bin/bash

# Variables - replace with your values
CLUSTER_NAME="topsurvey-dev-eks-cluster"
AWS_REGION="eu-west-1"

# Step 1: Verify AWS CLI is configured
echo "Verifying AWS CLI..."
aws sts get-caller-identity >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "AWS CLI is not properly configured. Please run 'aws configure'"
  exit 1
fi

# Step 2: Install Container Insights using a more manual approach
echo "Installing Container Insights with CloudWatch Agent and Fluent Bit..."

# Set necessary environment variables
export ClusterName=$CLUSTER_NAME
export RegionName=$AWS_REGION

# Download the quickstart file to make targeted modifications
QUICKSTART_FILE="cwagent-fluent-bit-quickstart.yaml"
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml > $QUICKSTART_FILE

# Explicitly set Fluent Bit configuration values
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
FluentBitReadFromTail='On'
FluentBitHttpServer='On'

# Perform all replacements
sed -i "s/{{cluster_name}}/${ClusterName}/g" $QUICKSTART_FILE
sed -i "s/{{region_name}}/${RegionName}/g" $QUICKSTART_FILE
sed -i "s/{{http_server_toggle}}/\"${FluentBitHttpServer}\"/g" $QUICKSTART_FILE
sed -i "s/{{http_server_port}}/\"${FluentBitHttpPort}\"/g" $QUICKSTART_FILE
sed -i "s/{{read_from_head}}/\"${FluentBitReadFromHead}\"/g" $QUICKSTART_FILE
sed -i "s/{{read_from_tail}}/\"${FluentBitReadFromTail}\"/g" $QUICKSTART_FILE

# Apply the configuration
echo "Applying modified configuration..."
kubectl apply -f $QUICKSTART_FILE

# Check if the installation was successful
if [ $? -eq 0 ]; then
  echo "Container Insights installation completed successfully!"
  echo "Verifying deployment..."
  echo "CloudWatch Agent pods:"
  kubectl get pods -n amazon-cloudwatch -l app=cloudwatch-agent
  echo "Fluent Bit pods:"
  kubectl get pods -n amazon-cloudwatch -l app=fluent-bit
else
  echo "Container Insights installation failed. Please check the logs for details."
  
  # Debug: Check what the YAML looks like after our replacements
  echo "Debugging YAML replacements. Grep for placeholder strings:"
  grep -n "{{" $QUICKSTART_FILE
fi