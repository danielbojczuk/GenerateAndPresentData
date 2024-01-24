resource "aws_vpc" "main_vpc" {
    cidr_block       = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "main-vpc-${terraform.workspace}"
    }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet-${terraform.workspace}"
  }
}

resource "aws_default_security_group" "default_security_group" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-security-group-${terraform.workspace}"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-1.logs"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "sqs_endpoint" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-1.sqs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [aws_subnet.private_subnet.id]
}