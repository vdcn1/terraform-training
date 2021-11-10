terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
  required_version = ">= 0.14.5"
}

provider "aws" {
  region = var.region
  shared_credentials_file = "/home/victorn/.aws/credentials"
}

resource "aws_security_group" "instance" {
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

# resource "aws_vpc" "vpc" {
#   cidr_block           = var.cidr_vpc
#   enable_dns_support   = true
#   enable_dns_hostnames = true
# }

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_subnet" "subnet_public" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = var.cidr_subnet
# }

# resource "aws_route_table" "rtb_public" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
# }

# resource "aws_route_table_association" "rta_subnet_public" {
#   subnet_id      = aws_subnet.subnet_public.id
#   route_table_id = aws_route_table.rtb_public.id
# }

# resource "aws_security_group" "sg_22_80" {
#   name   = "sg_22"
#   vpc_id = aws_vpc.vpc.id

#   # SSH access from the VPC
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_instance" "web" {
  ami                         = "ami-07ac00c72612e90ae"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.instance.id]

  tags = {
    Name  = var.name_tag
    Owner = var.owner_tag
  }
}

resource "aws_s3_bucket" "flugel_bucket_test" {
  bucket = "flugel-bucket-124981n9f87"
  tags = {
    Name  = var.name_tag
    Owner = var.owner_tag
  }
}