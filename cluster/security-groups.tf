# EKS Cluster Security Group
resource "aws_security_group" "cluster_security_group" {
  name        = "${var.eks.eks_cluster_name}-eks-cluster-sg"
  description = "Security group for ${var.eks.eks_cluster_name} cluster"
  vpc_id      = data.aws_subnet.aws_subnet1.vpc_id
  tags = var.tags
  ingress {
    description = "Unrestricted inbound rule for Spoke resource security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Unrestricted outbound rule for Spoke resource security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

