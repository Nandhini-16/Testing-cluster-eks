# EKS Node Security Group
resource "aws_security_group" "node_security_group" {
  name        = "${var.eks.cluster_name}-eks-node-sg"
  description = "Security group for ${var.eks.cluster_name} node"
  vpc_id      = data.aws_subnet.aws_subnet1.vpc_id
  tags        = {
      "kubernetes.io/cluster/demo-cluster-1" = "owned"
      "Name"                                 = "demo-cluster-1-eks-node-sg"
      "aws:eks:cluster-name"                 = "demo-cluster-1"
    }
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


resource "aws_eks_node_group" "eks_node_group" {
  for_each = var.node_groups
  ami_type               = "AL2_x86_64"
  capacity_type          = "ON_DEMAND"
  cluster_name    = var.eks.cluster_name
  disk_size              = 20
  force_update_version   = null
  instance_types         = ["t3.medium"]
  node_role_arn   = aws_iam_role.iam_node_role.arn
  node_group_name = each.key
  release_version        = "1.29.0-20240227"
  version                = "1.29"

  subnet_ids = [data.aws_subnet.aws_subnet1.id, data.aws_subnet.aws_subnet2.id]
  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.maximum_size
    min_size     = each.value.minimum_size
  }

  update_config {
    max_unavailable            = 1
  }
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = var.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.eks.ebs_csi_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn    = aws_iam_role.aws_ebs_csi_driver.arn
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}

resource "aws_eks_addon" "eks_coredns_addon" {
  cluster_name                = var.eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = var.eks.coredns_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}