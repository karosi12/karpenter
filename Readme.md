## OpsFleet Take-Home DevOps Challenge

## Instruction

Automate AWS EKS cluster setup with Karpenter, while utilizing Graviton and Spot instances.

## Technologies Used

- Terraform (Iac) to provision the infrastructure

## Important

- We have two infrastructure folder (0-eks and k8s)
- 0-eks is used to provisioned VPC, and EKS cluster.
- k8s is used to deploy kubernetes manifest script into the cluster.

## Requirements

- Inside 0-eks, create a variable file terraform.tfvars with below sample data

```
cluster_id                        = "opsfleet"
vpc_name                          = "opsfleet-vpc"
availability_zone1                = "eu-central-1a"
availability_zone2                = "eu-central-1b"
cidr_block                        = "10.0.0.0/16"
private_subnet_cidr_eu_central_1a = "10.0.1.0/24"
private_subnet_cidr_eu_central_1b = "10.0.10.0/24"
public_subnet_cidr_eu_central_1a  = "10.0.3.0/24"
public_subnet_cidr_eu_central_1b  = "10.0.4.0/24"
capacity_type                     = "SPOT"
account_id                        = "<ACCOUNT_ID>"
access_key                        = "<AWS_ACCESS_KEY>"
secret_key                        = "<AWS_SECRET_ACCESS_KEY>"
region                            = "<AWS_REGION>"
```

## Terraform command

- To Provision the infrastructure using terraform command afer changing directory to the Elastic Kubernetes Service (0-eks). Run below commands

```
terraform init
terraform plan
terraform apply # An instruction will be given to enter y for yes
terraform apply -auto-approve # This command is use to provision without typing the yes/y key word
```

## To run or deploy NodePool and ECNodeClass Mainfest

```
Note: After provisioning the infrastructure, Change directory into the k8s folder and deploy the karpenter.yaml file using below command.
```

kubectl apply -f karpenter.yaml first

## For scaling run below command

- To scale UP

kubectl scale deployment inflate --replicas 5

kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller

kubectl logs -f -n "${KARPENTER_NAMESPACE}" -l app.kubernetes.io/name=karpenter -c controller

- To scale DOWN 

Now, delete the deployment. After a short amount of time, Karpenter should terminate the empty nodes due to consolidation. [source](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/#7-scale-down-deployment)

kubectl delete deployment inflate

kubectl logs -f -n "${KARPENTER_NAMESPACE}" -l app.kubernetes.io/name=karpenter -c controller

## Resource used is the karpenter official website

- Getting started [Karpenter](https://karpenter.sh/docs/getting-started/)

## Contact info

- You can reach me via email for more clarification <ezeade4real@hotmail.com>
