resource "aws_vpc" "eks_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
  
    }
}

resource "aws_subnet" "public_subnet" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
        Name = "public-subnet-${count.index + 1}"
    }
}
resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = false
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
        Name = "private-subnet-${count.index + 1}"
    }
}

resource "aws_internet_gateway" "eks_igw" {
    vpc_id = aws_vpc.eks_vpc.id
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
    }
}


resource "aws_eip" "eip-nat" {
    count = length(var.public_subnet_cidrs)
    domain = "vpc"
}


resource "aws_nat_gateway" "nat_gw" {
    count = length(var.public_subnet_cidrs)
    allocation_id = aws_eip.eip-nat[count.index].id
    subnet_id = aws_subnet.public_subnet[count.index].id
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
        Name = "nat-gateway-${count.index + 1}"
    }
}


resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.eks_vpc.id
    route {
        cidr_block = "0.0.0/0"
        gateway_id = aws_internet_gateway.eks_igw.id
        }
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
        Name = "public-route-table"
    }
}

resource "aws_route_table" "private_rt" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.eks_vpc.id
    route {
        cidr_block = "0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
        }
    tags = {
        project = "EKS_using_Terraform"
        Environment = "dev"
        Name = "private-route-table-${count.index + 1}"
    }
}


resource "aws_route_table_association" "public_rt_assoc" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_rt[count.index].id
}

