provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "./cluster/"
  network = ({
    node_subnet_id_1 = "subnet-06639878fce5acaa7"
    node_subnet_id_2 = "subnet-0db9b9481b4ce4afa"
  })
  eks = ({
    eks_cluster_name               = "demo-cluster-1"
    eks_cluster_version            = "1.29"
  })
  required_addons = ({
    kube_proxy_major_version = "v1.29.0"
    kube_proxy_minor_version = "eksbuild.1"
    vpc_cni_major_version    = "v1.15.4"
    vpc_cni_minor_version    = "eksbuild.1"
    addon_region             = "us-east-1"
  })
  tags = {
    "kubernetes.io/cluster/demo-cluster" = "owned"
    "Name"                                 = "demo-cluster-eks-cluster-sg"
    "aws:eks:cluster-name"                 = "demo-cluster"
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
    node_subnet_id_1 = "subnet-06639878fce5acaa7"
    node_subnet_id_2 = "subnet-0db9b9481b4ce4afa"
  })
  eks = ({
    cluster_name          = module.eks.eks_cluster_name
    ebs_csi_addon_version = "v1.25.0-eksbuild.1"
    coredns_addon_version = "v1.10.1-eksbuild.6"
    node_ami_id           = "ami-0440d3b780d96b29d"
  })
  tags = {
    "kubernetes.io/cluster/demo-cluster" = "owned"
    "Name"                                 = "demo-cluster-eks-cluster-sg"
    "aws:eks:cluster-name"                 = "demo-cluster"
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

provider "kubernetes" {
  host                   = module.eks-nodes.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-nodes.eks_cluster_certificate_authority_data)
  token                  = module.eks-nodes.eks_cluster_token
}

provider "helm" {
  kubernetes {
    host                   = module.eks-nodes.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-nodes.eks_cluster_certificate_authority_data)
    token                  = module.eks-nodes.eks_cluster_token
  }
}

resource "kubernetes_namespace" "sample-nodejs" {
  metadata {
    name = "my-app"
  }
}

resource "kubernetes_deployment" "sample-nodejs" {
  metadata {
    name      = "my-app"
    namespace = kubernetes_namespace.sample-nodejs.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "my-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }
      spec {
        container {
          image = "dhiva007/my-app:latest"
          name  = "my-app"
          port {
            container_port = 5000
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "sample-nodejs" {
  metadata {
    name      = "my-app"
    namespace = kubernetes_namespace.sample-nodejs.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.sample-nodejs.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 5000
    }
  }
}

