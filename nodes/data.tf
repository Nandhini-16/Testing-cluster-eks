data "aws_eks_cluster" "eks_cluster" {
  name = var.eks.cluster_name
}

data "aws_subnet" "aws_subnet1" {
  id = var.network.node_subnet_id_1
}

data "aws_subnet" "aws_subnet2" {
  id = var.network.node_subnet_id_2
}

data "template_file" "init" {
  template = file("${path.module}/files/eks-node-userdata.tpl")
  vars = {
      apiserver-endpoint   = data.aws_eks_cluster.eks_cluster.endpoint
      b64-cluster-ca       = data.aws_eks_cluster.eks_cluster.certificate_authority.0.data
      eks-cluster-name     = data.aws_eks_cluster.eks_cluster.id
  }
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = data.aws_eks_cluster.eks_cluster.id
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}