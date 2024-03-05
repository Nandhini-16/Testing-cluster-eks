variable "eks_policy" {
  description = "The type of the instance."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]
}

############# iam trusted entity eks #############

data "aws_iam_policy_document" "iam_trusted_entity_eks" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam_cluster_role" {
  name               = "${var.eks.eks_cluster_name}-eks-iam-role"
  description        = "IAM Role for ${var.eks.eks_cluster_name} cluster"
  assume_role_policy = data.aws_iam_policy_document.iam_trusted_entity_eks.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  for_each   = { for policy in var.eks_policy : policy => policy }
  policy_arn = each.value
  role       = aws_iam_role.iam_cluster_role.name
}

