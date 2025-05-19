terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

  }
}

resource "aws_iam_role" "opsfleet" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "opsfleet-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.opsfleet.name
}

resource "aws_eks_cluster" "opsfleet" {
  name     = var.cluster_name
  role_arn = aws_iam_role.opsfleet.arn
  

  vpc_config {
    subnet_ids = var.subnet_ids
  }
  depends_on = [aws_iam_role_policy_attachment.opsfleet-AmazonEKSClusterPolicy]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.opsfleet.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks.url
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.34.0"

  create_role = true
  role_name   = "karpenter-controller"

  provider_url = data.tls_certificate.eks.url
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

resource "aws_iam_role" "karpenter_node" {
  name               = "KarpenterNodeRole"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume.json
}

data "aws_iam_policy_document" "karpenter_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "karpenter_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterInstanceProfile"
  role = aws_iam_role.karpenter_node.name
}

resource "null_resource" "karpenter_install" {
  depends_on = [
    aws_eks_cluster.opsfleet,
    aws_iam_role.karpenter_node,
    aws_iam_instance_profile.karpenter
  ]

  provisioner "local-exec" {
    environment = {
      AWS_REGION = var.region
      KUBECONFIG = pathexpand("~/.kube/config")
    }

    command = <<EOT
      #!/bin/bash
      set -e

      # Wait for EKS cluster to be ACTIVE
      # while true; do
      #   STATUS=$(aws eks describe-cluster --name ${var.cluster_name} --region ${var.region} --query "cluster.status" --output text)
      #   if [ "$STATUS" == "ACTIVE" ]; then
      #     echo "EKS cluster is active!"
      #     break
      #   fi
      #   echo "Waiting for EKS cluster to become active..."
      #   sleep 30
      # done

      # Update kubeconfig to ensure kubectl/helm can reach the cluster
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}

      # Wait for at least one Ready node
      # while true; do
      #   NODE_STATUS=$(kubectl get nodes --no-headers | awk '{print $2}')
      #   if [ "$NODE_STATUS" == "Ready" ]; then
      #     echo "Kubernetes node is Ready!"
      #     break
      #   fi
      #   echo "Waiting for Kubernetes node to be Ready..."
      #   sleep 20
      # done

      # Authenticate with public ECR
      aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

      # Optional: logout stale sessions
      # helm registry logout public.ecr.aws

      # Install Karpenter CRDs
      helm upgrade --install karpenter-crd oci://public.ecr.aws/karpenter/karpenter-crd --version 1.4.0 --namespace karpenter --create-namespace

      # Install Karpenter controller
      helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version 1.4.0 --namespace karpenter \
      --set controller.hostNetwork=true \
      --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${var.account_id}:role/karpenter-controller" \
      --set settings.clusterName=${var.cluster_name} \
      --set settings.clusterEndpoint=${aws_eks_cluster.opsfleet.endpoint} \
      --set settings.aws.defaultInstanceProfile=KarpenterInstanceProfile
    EOT
  }
}

