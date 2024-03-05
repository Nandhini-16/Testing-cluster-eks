variable "network" {
  description = <<-EOF
  Objects for the cluster security group id.

  Available options:
  - `node_subnet_id_1` = (Required|string) subnet id for node from az1.
  - `node_subnet_id_2` = (Required|string) subnet id for node from az2.
  - `pod_subnet_id_1`  = (Required|string) subnet id for pod from az1.
  - `pod_subnet_id_2`  = (Required|string) subnet id for pod from az2.

  Example:
  ```
  network = ({    
    node_subnet_id_1 = "subnet-0e0576807efad3bf0"
    node_subnet_id_2 = "subnet-03a10e5719b7a7cd6"
    pod_subnet_id_1  = "subnet-0e0576807efad3bf0"
    pod_subnet_id_2  = "subnet-03a10e5719b7a7cd6"
  })
  ```
  EOF
  type = object({
    node_subnet_id_1 = string
    node_subnet_id_2 = string
  })
}

variable "eks" {
  description = <<-EOF
  Objects for the EKS cluster.

  Available options:
  - `eks_cluster_name`               = (Required|string) Name of the EKS Cluster.
  - `eks_cluster_version`            = (Required|string) Kubernetes `<major>.<minor>` version to use for the EKS cluster. Please refer https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html for list of versions.
 
  Example:
  ```
  eks = ({    
    eks_cluster_name               = "ssd-eks-test"
    eks_cluster_version            = "1.28"
  })
  ```
  EOF
  type = object({
    eks_cluster_name               = string
    eks_cluster_version            = string
  })
}


variable "required_addons" {
  description = <<-EOF
  Objects for the required EKS add-on(s).

  Available options:
  - `kube_proxy_major_version` = (Optional|string) The major version of the kube-proxy add-on.
  - `kube_proxy_minor_version` = (Optional|string) The minor version of the kube-proxy add-on.
  - `vpc_cni_major_version`    = (Optional|string) The major version of the vpc cni add-on.
  - `vpc_cni_minor_version`    = (Optional|string) The minor version of the vpc cni add-on.
  - `addon_region`             = (Optional|string) The AWS region of the add-on.

  Example:
  ```
  required_addons = ({    
    kube_proxy_major_version = "v1.28.2"
    kube_proxy_minor_version = "eksbuild.2"
    vpc_cni_major_version    = "v1.15.4"
    vpc_cni_minor_version    = "eksbuild.1"
    addon_region             = "us-east-1"
  })
  ```
  EOF
  type = object({
    kube_proxy_major_version = optional(string, "v1.28.2")
    kube_proxy_minor_version = optional(string, "eksbuild.2")
    vpc_cni_major_version    = optional(string, "v1.15.4")
    vpc_cni_minor_version    = optional(string, "eksbuild.1")
    addon_region             = optional(string, "us-east-1")
  })
}


variable "tags" {
  description = "Tag(s) to apply to resources being created."
  type = any
}






