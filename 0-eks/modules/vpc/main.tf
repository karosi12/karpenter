resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
    "kubernetes.io/cluster/eks-karpenter" = "shared"
  }
}
# private subnet
resource "aws_subnet" "private_subnet_eu_central_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_eu_central_1a
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.vpc_name}-private-subnet-${var.availability_zone1}"
  }
}

resource "aws_subnet" "private_subnet_eu_central_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_eu_central_1b
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.vpc_name}-private-subnet-${var.availability_zone2}"
  }
}

# public subnet
resource "aws_subnet" "public_subnet_eu_central_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_eu_central_1a
  availability_zone = var.availability_zone1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet-${var.availability_zone1}"
  }
}

resource "aws_subnet" "public_subnet_eu_central_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_eu_central_1b
  availability_zone = var.availability_zone2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet--${var.availability_zone2}"
  }
}


