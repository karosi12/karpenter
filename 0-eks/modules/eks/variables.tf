variable "subnet_ids" {
  type        = list(string)
  description = "subnet ids"
}

variable "cluster_name" {
  type        = string
  description = "AWS EKS CLuster Name"
  nullable    = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "private subnet ids"
}

variable "region" {
  type    = string
}
variable "account_id" {
  type        = string
  description = "AWS ACCOUNT ID"
}

variable "capacity_type" {
  type        = string
  description = "Capacity type"
}
