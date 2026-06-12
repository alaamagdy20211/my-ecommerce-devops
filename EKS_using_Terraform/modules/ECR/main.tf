# ─────────────────────────────────────────────────────────────
# ECR Repositories for each app tier
# ─────────────────────────────────────────────────────────────
resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = "${var.cluster_name}/${each.key}"
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}"
  })
}

# ─────────────────────────────────────────────────────────────
# Lifecycle policy: keep last N images to control storage cost
# ─────────────────────────────────────────────────────────────
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = var.repositories
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.images_to_keep} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.images_to_keep
      }
      action = { type = "expire" }
    }]
  })
}

# ─────────────────────────────────────────────────────────────
# Repository policy: allow the EKS node role to pull images
# ─────────────────────────────────────────────────────────────
resource "aws_ecr_repository_policy" "this" {
  for_each   = var.repositories
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowEKSNodePull"
      Effect = "Allow"
      Principal = {
        AWS = var.node_role_arn
      }
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
      ]
    }]
  })
}