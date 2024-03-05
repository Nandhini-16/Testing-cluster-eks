############# iam trusted entity nodes #############

data "aws_iam_policy_document" "iam_trusted_entity_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam_node_role" {
  name               = "${var.eks.cluster_name}-eks-node-iam-role"
  description        = "IAM Role for ${var.eks.cluster_name} node"
  assume_role_policy = data.aws_iam_policy_document.iam_trusted_entity_ec2.json
}

resource "aws_iam_role_policy_attachment" "node_role_policy_attachment" {
  for_each   = { for policy in var.node_policy : policy => policy }
  policy_arn = each.value
  role       = aws_iam_role.iam_node_role.name
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "ebs_cni_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.ebs_cni_assume_role_policy.json
  name               = "${var.eks.cluster_name}-aws-ebs-csi-driver-role"
}


resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver_default" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.aws_ebs_csi_driver.name
}

data "aws_iam_policy_document" "aws_ebs_csi_driver" {

  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_ebs_csi_driver" {
  name   = "${var.eks.cluster_name}-ebs-csi-driver-policy"
  policy = data.aws_iam_policy_document.aws_ebs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver" {
  policy_arn = aws_iam_policy.aws_ebs_csi_driver.arn
  role       = aws_iam_role.aws_ebs_csi_driver.name
}