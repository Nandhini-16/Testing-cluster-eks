data "aws_subnet" "aws_subnet1" {
  id = var.network.node_subnet_id_1
}

data "aws_subnet" "aws_subnet2" {
  id = var.network.node_subnet_id_2
}

resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.eks.eks_cluster_name
  role_arn                  = aws_iam_role.iam_cluster_role.arn
  version                   = var.eks.eks_cluster_version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [data.aws_subnet.aws_subnet1.id, data.aws_subnet.aws_subnet2.id]
    security_group_ids      = [aws_security_group.cluster_security_group.id]
  }
  tags = var.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.id
  addon_name                  = "kube-proxy"
  addon_version               = "${var.required_addons.kube_proxy_major_version}-${var.required_addons.kube_proxy_minor_version}"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.id
  addon_name                  = "vpc-cni"
  addon_version               = "${var.required_addons.vpc_cni_major_version}-${var.required_addons.vpc_cni_minor_version}"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}
