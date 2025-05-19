output "vpc_id" {
  value = module.vpc.vpc_id
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}