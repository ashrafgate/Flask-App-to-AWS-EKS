output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS Cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS Cluster API endpoint"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Cluster CA certificate data"
}

output "cluster_arn" {
  value       = aws_eks_cluster.main.arn
  description = "EKS Cluster ARN"
}

output "node_group_name" {
  value       = aws_eks_node_group.default.node_group_name
  description = "EKS Node Group name"
}
