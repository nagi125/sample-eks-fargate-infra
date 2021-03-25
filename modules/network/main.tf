variable "app_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.app_name
  }
}

# Subnets(Public)
resource "aws_subnet" "publics" {
  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  availability_zone = var.azs[count.index]
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = {
    Name = "${var.app_name}-public-${count.index}"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${app_name}" = "shared"
  }
}

# Subnet(Private)
resource "aws_subnet" "privates" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  availability_zone = var.azs[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.app_name}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${app_name}" = "shared"
  }
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}

# NAT(EIP)
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.app_name}-natgw"
  }
}

# NAT(GW)
resource "aws_nat_gateway" "main" {

  subnet_id = aws_subnet.publics.0.id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "${var.app_name}"
  }
}

# RouteTable(Public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-public"
  }
}

# Route(Public)
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.main.id
}

# RouteTableAssociation(Public)
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id = element(aws_subnet.publics.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# RouteTable(Private)
resource "aws_route_table" "privates" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-private-${count.index}"
  }
}

# Route(Private)
resource "aws_route" "privates" {
  count = length(var.private_subnet_cidrs)

  destination_cidr_block = "0.0.0.0/0"

  route_table_id = element(aws_route_table.privates.*.id, count.index)
  nat_gateway_id = aws_nat_gateway.main.id
}

# RouteTableAssociation(Privates)
resource "aws_route_table_association" "privates" {
  count = length(var.private_subnet_cidrs)

  subnet_id = element(aws_subnet.privates.*.id, count.index)
  route_table_id = element(aws_route_table.privates.*.id, count.index)
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.publics.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.privates.*.id
}
