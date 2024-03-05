output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_name" {
  description = "The ID or Name of the cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.eks_cluster.endpoint
}
