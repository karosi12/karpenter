#!/bin/bash

cat <<EOF >terraform.tfvars
cluster_id = "$CLUSTER_ID"
vpc_name = "$VPC_NAME"
access_key = "$AWS_ACCESS_KEY_ID"
secret_key = "$AWS_SECRET_ACCESS_KEY"
region = "$REGION"
availability_zone1 = "$AZ1"
availability_zone2 = "$AZ2"
cidr_block = "$CIDR_BLOCK"
account_id = "$ACCOUNT_ID"
private_subnet_cidr_eu_central_1a = "$PRIVATE_SUBNET1"
private_subnet_cidr_eu_central_1b = "$PRIVATE_SUBNET2"
public_subnet_cidr_eu_central_1a = "$PUBLIC_SUBNET1"
public_subnet_cidr_eu_central_1b = "$PUBLIC_SUBNET2"
EOF
