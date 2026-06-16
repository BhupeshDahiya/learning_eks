resource "aws_subnet" "pvt_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.zone1

  tags = {
    Name                              = "${local.env}-pvt-${local.zone1}"
    "kubernetes.io/role/internal-elb" = "1" # Tag to deploy load balancers to a pvt subnet
  }
}

resource "aws_subnet" "pvt_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.zone2

  tags = {
    Name                              = "${local.env}-pvt-${local.zone2}"
    "kubernetes.io/role/internal-elb" = "1" # Tag to deploy load balancers to a pvt subnet
  }
}

resource "aws_subnet" "pub_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = local.zone1
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${local.env}-pub-${local.zone1}"
    "kubernetes.io/role/elb" = "1" # Tag to deploy load balancers to a pvt subnet
  }
}

resource "aws_subnet" "pub_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${local.env}-pub-${local.zone2}"
    "kubernetes.io/role/elb" = "1" # Tag to deploy load balancers to a pvt subnet
  }
}