output "cluster_name" {
  value = aws_eks_cluster.opsfleet.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.opsfleet.endpoint
}

output "oidc_url" {
  value = aws_iam_openid_connect_provider.eks.url
}


output "kubeconfig" {
  value = <<EOT
apiVersion: v1
kind: Config
clusters:
- name: ${aws_eks_cluster.opsfleet.name}
  cluster:
    server: ${aws_eks_cluster.opsfleet.endpoint}
    certificate-authority-data: ${aws_eks_cluster.opsfleet.certificate_authority[0].data}
contexts:
- name: ${aws_eks_cluster.opsfleet.name}
  context:
    cluster: ${aws_eks_cluster.opsfleet.name}
    user: aws
current-context: ${aws_eks_cluster.opsfleet.name}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
      - eks
      - get-token
      - --region
      - ${var.region}
  EOT
}
