output "cluster_name" {
  value = aws_eks_cluster.opsfleet.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.opsfleet.endpoint
}

output "oidc_url" {
  value = aws_iam_openid_connect_provider.eks.url
}