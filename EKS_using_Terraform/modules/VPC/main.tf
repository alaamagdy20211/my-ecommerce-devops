# resource "aws_vpc" "eks_vpc" {
#     cidr_block = var.vpc_cidr
#     enable_dns_support = true
#     enable_dns_hostnames = true
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
  
#     }
# }

# resource "aws_subnet" "public_subnet" {
#     count = length(var.public_subnet_cidrs)
#     vpc_id = aws_vpc.eks_vpc.id
#     cidr_block = var.public_subnet_cidrs[count.index]
#     availability_zone = var.availability_zones[count.index]
#     map_public_ip_on_launch = true
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
#         Name = "public-subnet-${count.index + 1}"
#     }
# }
# resource "aws_subnet" "private_subnet" {
#     count = length(var.private_subnet_cidrs)
#     vpc_id = aws_vpc.eks_vpc.id
#     cidr_block = var.private_subnet_cidrs[count.index]
#     availability_zone = var.availability_zones[count.index]
#     map_public_ip_on_launch = false
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
#         Name = "private-subnet-${count.index + 1}"
#     }
# }

# resource "aws_internet_gateway" "eks_igw" {
#     vpc_id = aws_vpc.eks_vpc.id
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
#     }
# }


# resource "aws_eip" "eip-nat" {
#     count = length(var.public_subnet_cidrs)
#     domain = "vpc"
# }


# resource "aws_nat_gateway" "nat_gw" {
#     count = length(var.public_subnet_cidrs)
#     allocation_id = aws_eip.eip-nat[count.index].id
#     subnet_id = aws_subnet.public_subnet[count.index].id
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
#         Name = "nat-gateway-${count.index + 1}"
#     }
# }


# resource "aws_route_table" "public_rt" {
#     vpc_id = aws_vpc.eks_vpc.id
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.eks_igw.id
#         }
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
#         Name = "public-route-table"
#     }
# }

# resource "aws_route_table" "private_rt" {
#     count = length(var.private_subnet_cidrs)
#     vpc_id = aws_vpc.eks_vpc.id
#     route {
#         cidr_block = "0.0.0.0/0"
#         nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
#         }
#     tags = {
#         project = "EKS_using_Terraform"
#         Environment = "dev"
#         Name = "private-route-table-${count.index + 1}"
#     }
# }


# resource "aws_route_table_association" "public_rt_assoc" {
#     count = length(var.public_subnet_cidrs)
#     subnet_id = aws_subnet.public_subnet[count.index].id
#     route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table_association" "private_rt_assoc" {
#     count = length(var.private_subnet_cidrs)
#     subnet_id = aws_subnet.private_subnet[count.index].id
#     route_table_id = aws_route_table.private_rt[count.index].id
# }

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc"
    # Required tags for EKS to discover the VPC
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-public-subnet-${count.index + 1}"
    # Required tag for EKS to use these subnets for public Load Balancers (ALB)
    "kubernetes.io/role/elb"                            = "1"
    "kubernetes.io/cluster/${var.cluster_name}"         = "shared"
  })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private-subnet-${count.index + 1}"
    # Required tag for EKS to use these subnets for internal Load Balancers
    "kubernetes.io/role/internal-elb"                   = "1"
    "kubernetes.io/cluster/${var.cluster_name}"         = "shared"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-igw"
  })
}

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = length(var.public_subnet_cidrs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-gw-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}