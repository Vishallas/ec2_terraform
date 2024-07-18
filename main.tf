provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "custom" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "custom" {
  vpc_id     = aws_vpc.custom.id
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "custom_subnet_1"
  }
}

resource "aws_internet_gateway" "custom" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "custom_gw"
  }
}

resource "aws_route_table" "custom" {
  vpc_id = aws_vpc.custom.id
  tags = {
    Name = "custom_route_table"
  }
}

resource "aws_route" "custom" {
  route_table_id         = aws_route_table.custom.id
  gateway_id             = aws_internet_gateway.custom.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "example_http" {
  security_group_id = aws_security_group.custom.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  tags = {
    Name = "Rule for http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "example_ssh" {
  security_group_id = aws_security_group.custom.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  tags = {
    Name = "Rule for http"
  }
}

resource "aws_vpc_security_group_egress_rule" "example_ssh" {
  security_group_id = aws_security_group.custom.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "rule to allow all outbound traffic"
  }
}

resource "aws_security_group" "custom" {
  vpc_id = aws_vpc.custom.id
  tags = {
    Name = "Security group for ec2 instance"
  }
}

resource "aws_iam_role" "custom" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "ec2_role_for_s3_ses"
  }
}

locals {
  ami = "ami-0ec0e125bb6c6e8ec"
  s3FullAccessArn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  sesFullAccessArn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy_attachment" "custom_s3_attach" {
  role = aws_iam_role.custom.name
  policy_arn = local.s3FullAccessArn
}

resource "aws_iam_role_policy_attachment" "custom_ses_attach" {
  role = aws_iam_role.custom.name
  policy_arn = local.sesFullAccessArn
}

resource "aws_iam_instance_profile" "custom" {
  name = "ec2_role_for_s3_ses"
  role = aws_iam_role.custom.name
}

resource "aws_instance" "custom" {
  ami             = local.ami
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.custom.id
  iam_instance_profile = aws_iam_instance_profile.custom.name
  security_groups = [aws_security_group.custom.id]
  tags = {
    Name = "custom_ec2_instance"
  }
}

resource "aws_eip" "custom" {
  instance = aws_instance.custom.id
  domain   = "vpc"
}