# resource "aws_iam_role" "eks_role" {
#   name = "${var.eks_cluster_name}-eks-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       },
#     ]
#   })


# }

# resource "aws_iam_role_policy_attachment" "eks_role_attachment" {
#   role       = aws_iam_role.eks_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }


# resource "aws_eks_cluster" "eks_cluster" {
#   name     = var.eks_cluster_name
#   role_arn = aws_iam_role.eks_role.arn
#   version  = var.cluster_version

#   vpc_config {
#     subnet_ids = var.subnet_ids
#   }

#   depends_on = [aws_iam_role_policy_attachment.eks_role_attachment]
# }


# resource "aws_iam_role" "eks_node_role" {
#   name = "${var.eks_cluster_name}-node-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })


# }


# resource "aws_iam_role_policy_attachment" "eks_node_role_attachment" {
#     for_each = toset (
#         [
#             "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#             "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
#             "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#         ]
#     )
#     role       = aws_iam_role.eks_node_role.name
#     policy_arn = each.value
# }



# resource "aws_eks_node_group" "eks_node_group" {
#   for_each = var.node_groups

#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "${var.eks_cluster_name}-node-group-${each.key}"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = var.subnet_ids

#   scaling_config {
#     desired_size = each.value.scaling_config.desired_size
#     max_size     = each.value.scaling_config.max_size
#     min_size     = each.value.scaling_config.min_size
#   }

#   instance_types = each.value.instance_types
#   depends_on = [aws_iam_role_policy_attachment.eks_node_role_attachment]
# }

# ─────────────────────────────────────────────────────────────
# EKS Control Plane IAM Role
# ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ─────────────────────────────────────────────────────────────
# EKS Cluster
# ─────────────────────────────────────────────────────────────
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# ─────────────────────────────────────────────────────────────
# OIDC Provider (needed for IRSA and Pod Identity)
# ─────────────────────────────────────────────────────────────
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────
# EKS Node Group IAM Role
# ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "node_group" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ])

  role       = aws_iam_role.node_group.name
  policy_arn = each.value
}

# ─────────────────────────────────────────────────────────────
# Node Groups
# ─────────────────────────────────────────────────────────────
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  # Allow rolling updates without destroying the node group
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}"
  })

  depends_on = [aws_iam_role_policy_attachment.node_policies]
}

# ─────────────────────────────────────────────────────────────
# Pod Identity Addon (required for EKS Pod Identity)
# ─────────────────────────────────────────────────────────────
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"

  tags = var.tags

  depends_on = [aws_eks_node_group.this]
}