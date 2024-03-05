provider "aws" {
  region = "us-east-2"
}

module "eks" {
  source = "./cluster/"
  network = ({
    node_subnet_id_1 = "subnet-03386e05568547fec"
    node_subnet_id_2 = "subnet-0d6f9d66cd2094e22"
  })
  eks = ({
    eks_cluster_name               = "test-cluster-1"
    eks_cluster_version            = "1.29"
  })
  required_addons = ({
    kube_proxy_major_version = "v1.29.0"
    kube_proxy_minor_version = "eksbuild.1"
    vpc_cni_major_version    = "v1.15.4"
    vpc_cni_minor_version    = "eksbuild.1"
    addon_region             = "us-east-2"
  })
  tags = {
    "kubernetes.io/cluster/test-cluster-1" = "owned"
    "Name"                                 = "test-cluster-1-eks-cluster-sg"
    "aws:eks:cluster-name"                 = "test-cluster-1"
  }
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.eks_cluster_arn
}


data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks.eks_cluster_name
}


module "eks-nodes" {
  source = "./nodes"
  network = ({
    node_subnet_id_1 = "subnet-03386e05568547fec"
    node_subnet_id_2 = "subnet-0d6f9d66cd2094e22"
  })
  eks = ({
    cluster_name          = module.eks.eks_cluster_name
    ebs_csi_addon_version = "v1.25.0-eksbuild.1"
    coredns_addon_version = "v1.10.1-eksbuild.6"
    node_ami_id           = "ami-0f5daaa3a7fb3378b"
  })
  tags = {
    "kubernetes.io/cluster/tesr-cluster-1" = "owned"
    "Name"                                 = "test-cluster-1-eks-cluster-sg"
    "aws:eks:cluster-name"                 = "test-cluster-1"
  }
  node_groups = {
    template1 = {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp3"
      instance_type         = "t3.large"
      desired_size          = 2
      maximum_size          = 3
      minimum_size          = 1
    },
    # template2 = {
    #   delete_on_termination = true
    #   volume_size           = 80
    #   volume_type           = "gp3"
    #   instance_type         = "t3.xlarge"
    #   desired_size          = 2
    #   maximum_size          = 3
    #   minimum_size          = 1
    # }
  }
}

