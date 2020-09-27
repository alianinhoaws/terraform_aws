
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}



resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  vpc   = true
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-route-private-subnet-${count.index + 1}"
  }
}



//
//
//resource "aws_route_table_association" "private_routes" {
//  count          = length(aws_subnet.private_subnets[*].id)
//  route_table_id = aws_route_table.private_subnets[count.index].id
//  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
//}
//
//
//
//
//resource "aws_route_table_association" "route_internet_association_A" {
//
//  provider = aws
//
//  route_table_id = aws_route_table.route_internet.id
//
//  subnet_id = aws_subnet.publicA.id
//
//}
//
//resource "aws_route_table_association" "route_internet_association_B" {
//
//  provider = aws
//
//  route_table_id = aws_route_table.route_internet.id
//
//  subnet_id = aws_subnet.publicB.id
//
//}
//
//resource "aws_route_table" "route_internet" {
//  vpc_id = aws_vpc.main.id
//
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_internet_gateway.internet_gateway.id
//  }
//
//  tags = {
//    Name = "main-internet"
//  }
//}
//
//
//resource "aws_route_table_association" "route_nat_association_A" {
//
//  provider = aws
//
//  route_table_id = aws_route_table.route_nat_A.id
//
//  subnet_id = aws_subnet.privateA.id
//
//}
//
//
//resource "aws_route_table_association" "route_nat_association_B" {
//
//  provider = aws
//
//  route_table_id = aws_route_table.route_nat_B.id
//
//  subnet_id = aws_subnet.privateB.id
//
//}
//
//
//resource "aws_route_table" "route_nat_A" {
//  vpc_id = aws_vpc.main.id
//
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_nat_gateway.gwA.id
//  }
//
//  tags = {
//    Name = "NAT-A"
//  }
//}
//
//resource "aws_route_table" "route_nat_B" {
//  vpc_id = aws_vpc.main.id
//
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_nat_gateway.gwB.id
//  }
//
//  tags = {
//    Name = "NAT-B"
//  }
//}
//
////resource "aws_route" "route_internet_gateway" {
////
////  route_table_id         = "igw-123132133123"
////  destination_cidr_block = "0.0.0.0/0"
////  gateway_id             = aws_internet_gateway.internet_gateway.id
////  depends_on = [aws_internet_gateway.internet_gateway]
////
//////  timeouts {
//////    create = "5m"
//////  }
////}
//
//data "aws_availability_zones" "available" {}
//
//resource "aws_internet_gateway" "internet_gateway" {
//  vpc_id = aws_vpc.main.id
//
//  tags = {
//    Name = "main"
//  }
//}
//
//resource "aws_subnet" "privateB" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.22.0/24"
//  map_public_ip_on_launch = false
//  availability_zone = data.aws_availability_zones.available.names[1]
//
//  tags = {
//    Name = "Private-B ${data.aws_availability_zones.available.names[0]}"
//  }
//}
//resource "aws_subnet" "publicA" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.11.0/24"
//  map_public_ip_on_launch = true
//  availability_zone = data.aws_availability_zones.available.names[0]
//
//  tags = {
//    Name = "Public-A ${data.aws_availability_zones.available.names[0]}"
//  }
//}
//
//resource "aws_subnet" "publicB" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.21.0/24"
//  availability_zone = data.aws_availability_zones.available.names[1]
//  map_public_ip_on_launch = true
//
//  tags = {
//    Name = "Public-B ${data.aws_availability_zones.available.names[1]}"
//  }
//}
//
//resource "aws_subnet" "privateA" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.12.0/24"
//  availability_zone = data.aws_availability_zones.available.names[0]
//  map_public_ip_on_launch = false
//
//  tags = {
//    Name = "Private-A ${data.aws_availability_zones.available.names[0]}"
//  }
//}
//resource "aws_subnet" "database1" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.32.0/24"
//  availability_zone = data.aws_availability_zones.available.names[0]
//  map_public_ip_on_launch = false
//
//  tags = {
//    Name = "DB subnet 1 ${data.aws_availability_zones.available.names[0]}"
//  }
//}
//
//resource "aws_subnet" "database2" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = "10.0.31.0/24"
//  availability_zone = data.aws_availability_zones.available.names[1]
//  map_public_ip_on_launch = false
//
//  tags = {
//    Name = "DB subnet 2 ${data.aws_availability_zones.available.names[1]}"
//  }
//}
//
//resource "aws_nat_gateway" "gwB" {
//  allocation_id = aws_eip.nat[1].id
//  subnet_id     = aws_subnet.publicB.id
//
//  tags = {
//    Name = "gw NAT B"
//  }
//  depends_on = [aws_eip.nat[1], aws_subnet.privateB]
//}
//
//resource "aws_nat_gateway" "gwA" {
//  allocation_id = aws_eip.nat[0].id
//  subnet_id     = aws_subnet.publicA.id
//
//  tags = {
//    Name = "gw NAT A"
//  }
//  depends_on = [aws_eip.nat[0], aws_subnet.privateA]
//}
//
////resource "aws_network_interface" "multi-ip" {
////  subnet_id   = aws_subnet.main.id
////  private_ips = ["10.0.0.10", "10.0.0.11"]
////}

////resource "aws_eip" "nat" {
////  count = 2
////
////  vpc = true
////}
//resource "aws_elb" "web" {
//
//  name = "WebServer-ASG"
//  #availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
//  security_groups = [aws_security_group.web.id]
//  subnets = [aws_subnet.publicA.id,aws_subnet.publicB.id]
//
//
//  listener {
//    instance_port       = 80
//    instance_protocol   = "http"
//    lb_port             = 80
//    lb_protocol         = "http"
//
//  }
//  tags = merge(var.tags, {Name = "${var.tags["Environment"]} Server IP"})
//  health_check {
//    healthy_threshold   = 2
//    interval            = 10
//    target              = "HTTP:80/"
//    timeout             = 3
//    unhealthy_threshold = 2
//  }
//  depends_on = [aws_security_group.web]
//}
