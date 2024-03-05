### IAM roles ###

variable "node_policy" {
  description = "The IAM policies which needs to be attached to IAM Node role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

### network ###
variable "network" {
  description = <<-EOF
  Objects for the node security group id.

  Available options:
  - `node_subnet_id_1`          = (Required|string) subnet id for node from az1.
  - `node_subnet_id_2`            = (Required|string) subnet id for node from az2.
  - `pod_subnet_id_1`          = (Required|string) subnet id for pod from az1.
  - `pod_subnet_id_2`            = (Required|string) subnet id for pod from az2.

  Example:
  ```
  network = ({    
    node_subnet_id_1       = "subnet-0e0576807efad3bf0"
    node_subnet_id_2       = "subnet-03a10e5719b7a7cd6"
    pod_subnet_id_1       = "subnet-0e0576807efad3bf0"
    pod_subnet_id_2       = "subnet-03a10e5719b7a7cd6"
  })
  ```
  EOF
  type = object({
    node_subnet_id_1 = string
    node_subnet_id_2 = string
    #pod_subnet_id_1  = string
    #pod_subnet_id_2  = string
  })
}


### eks ###

variable "eks" {
  description = <<-EOF
  Objects for the EKS nodes.

  Available options:
  - `cluster_name`          = (Required|string) Name of the EKS Cluster.
  - `ebs_csi_addon_version` = optional(string, "v1.24.0-eksbuild.1") The version of the EKS EBS CSI driver add-on.
  - `coredns_addon_version` = optional(string, "v1.10.1-eksbuild.5") The version of the EKS coredns add-on.
  - `node_ami_id` = (Required|string) The AMI from which to launch the instance.
  
  Example:
  ```
  eks = ({    
    cluster_name = "ssd-eks-temp"
    ebs_csi_addon_version = "v1.24.0-eksbuild.1"
    coredns_addon_version = "v1.10.1-eksbuild.5"
    node_ami_id = "ami-04bb6de45022a5c0a"
  })
  ```
  EOF
  type = object({
    cluster_name          = string
    ebs_csi_addon_version = optional(string, "v1.24.0-eksbuild.1")
    coredns_addon_version = optional(string, "v1.10.1-eksbuild.5")
    node_ami_id           = string
  })
}


variable "tags" {
  description = <<EOF
  (Required) Tag(s) to apply to resources being created.
  `App_Name` - (Required | string)
  `App_Env` - (Required | string)
  `App_Owner` - (Required | string)
  `subCost_Center` - (Required | string)
  `Cost_Center` - (Required | string)
  `Project_Name` - (Required | string)
  `ServiceNow_Workgroup` - (Required | string)
  `Data_Classification` - (Optional | string)
  `custom` - (Optional | map)
  EOF
  type = any
}

variable "node_groups" {
  description = <<-EOF
  Objects for the Node group.

  Available options:
  - `delete_on_termination`                    = optional(bool, false) Whether the volume should be destroyed on instance termination. Defaults to false if not set.
  - `volume_size`            =  optional(number, 50) The size of the volume in gigabytes
  - `volume_type`                    = optional(string, "gp3") The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'standard').
  - `instance_type`            = optional(string, "t3.large") The type of the instance.
  - `desired_size`                    = optional(number, 2).
  - `maximum_size`          = optional(number, 3).
  - `minimum_size`            = optional(number, 1).

  Example:
  ```
  template1 = { 
    delete_on_termination                 = true
    volume_size       = 50
    volume_type                 = "gp3"
    instance_type       = "t3.large"
    desired_size          = 2
    maximum_size          = 3
    minimum_size          = 1
  },
  template2 = { 
    delete_on_termination                 = true
    volume_size       = 50
    volume_type                 = "gp3"
    instance_type       = "t3.xlarge"
    desired_size          = 2
    maximum_size          = 3
    minimum_size          = 1
  }

  ```
  EOF
  type = map(object({
    delete_on_termination = optional(bool, false)
    volume_size           = optional(number, 50)
    volume_type           = optional(string, "gp3")
    instance_type         = optional(string, "t3.large")
    desired_size          = optional(number, 2)
    maximum_size          = optional(number, 3)
    minimum_size          = optional(number, 1)
  }))
}

variable "kms_key_id" {
  description = <<EOF
  (Required | string) (Required|string) The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. 
  Encrypted must be set to true when this is set.ed.
  EOF
  type        = string
  default     = null
}
