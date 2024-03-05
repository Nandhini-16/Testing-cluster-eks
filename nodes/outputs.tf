# output "eks_node_pools_id" {
#   description = "EKS Cluster name and EKS Node Group name separated by a colon (:)."
#   value       = local.eks_node_group_ids
# }

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = data.aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_name" {
  description = "The ID or Name of the cluster"
  value       = data.aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = data.aws_eks_cluster.eks_cluster.certificate_authority.0.data
  sensitive   = true
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = data.aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_token" {
  description = "Auth token for EKS cluster"
  value       = data.aws_eks_cluster_auth.eks_cluster_auth.token
  sensitive   = true
}