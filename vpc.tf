# VPC
resource "aws_vpc" "project2-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project2-vpc"
  }
}

# Public Subnets 
resource "aws_subnet" "project2-pub-sub-1" {
  vpc_id            = aws_vpc.project2-vpc.id
  cidr_block        = "10.0.0.0/18"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "project2-pub-sub-1"
  }
}

resource "aws_subnet" "project2-pub-sub-2" {
  vpc_id            = aws_vpc.project2-vpc.id
  cidr_block        = "10.0.64.0/18"
  availability_zone = "eu-north-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "project2-pub-sub-2"
  }
}

# Private Subnets
resource "aws_subnet" "project2-pvt-sub-1" {
  vpc_id                  = aws_vpc.project2-vpc.id
  cidr_block              = "10.0.128.0/18"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "project2-pvt-sub-1"
  }
}
resource "aws_subnet" "project2-pvt-sub-2" {
  vpc_id                  = aws_vpc.project2-vpc.id
  cidr_block              = "10.0.192.0/18"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "project2-pvt-sub-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "project2-igw" {
  tags = {
    Name = "project2-igw"
  }
  vpc_id = aws_vpc.project2-vpc.id
}

# Route Table
resource "aws_route_table" "project2-rt" {
  tags = {
    Name = "project2-rt"
  }
  vpc_id = aws_vpc.project2-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project2-igw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "project2-rt-as-1" {
  subnet_id      = aws_subnet.project2-pub-sub-1.id
  route_table_id = aws_route_table.project2-rt.id
}

resource "aws_route_table_association" "project2-rt-as-2" {
  subnet_id      = aws_subnet.project2-pub-sub-2.id
  route_table_id = aws_route_table.project2-rt.id
}


# Create Load balancer
resource "aws_lb" "project2-lb" {
  name               = "project2-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project2-alb-sg.id]
  subnets            = [aws_subnet.project2-pub-sub-1.id, aws_subnet.project2-pub-sub-2.id]

  tags = {
    Environment = "project2-lb"
  }
}

resource "aws_lb_target_group" "project2-lb-tg" {
  name     = "project2-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.project2-vpc.id
}

# Create Load Balancer listener
resource "aws_lb_listener" "project2-lb-listner" {
  load_balancer_arn = aws_lb.project2-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project2-lb-tg.arn
  }
}

# Create Target group
resource "aws_lb_target_group" "project2-loadb_target" {
  name       = "target"
  depends_on = [aws_vpc.project2-vpc]
  port       = "80"
  protocol   = "HTTP"
  vpc_id     = aws_vpc.project2-vpc.id
  
}

resource "aws_lb_target_group_attachment" "project2-tg-attch-1" {
  target_group_arn = aws_lb_target_group.project2-loadb_target.arn
  target_id        = aws_instance.project2-web-server-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "project2-tg-attch-2" {
  target_group_arn = aws_lb_target_group.project2-loadb_target.arn
  target_id        = aws_instance.project2-web-server-2.id
  port             = 80
}

# Subnet group database
resource "aws_db_subnet_group" "project2-db-sub" {
  name       = "project2-db-sub"
  subnet_ids = [aws_subnet.project2-pvt-sub-1.id, aws_subnet.project2-pvt-sub-2.id]
}
