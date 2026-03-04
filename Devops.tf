terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.34.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

resource "aws_vpc" "Devops" {
  cidr_block       = "171.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Devops_Vpc"
  }
}

#Subnet

resource "aws_subnet" "devsub1" {
  vpc_id     = aws_vpc.Devops.id
  cidr_block = "171.0.0.0/17"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Devops_SUB1"
  }
}

resource "aws_subnet" "devsub2" {
  vpc_id     = aws_vpc.Devops.id
  cidr_block = "171.0.128.0/18"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Devops_SUB2"
  }
}

resource "aws_subnet" "devsub3" {
  vpc_id     = aws_vpc.Devops.id
  cidr_block = "171.0.192.0/27"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Devops_SUB3"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "devIgw" {
  vpc_id = aws_vpc.Devops.id

  tags = {
    Name = "Devops_IGW"
  }
}

#Route table
resource "aws_route_table" "devRt" {
  vpc_id = aws_vpc.Devops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devIgw.id

  }

  tags = {
    Name = "Devops_RT"
  }
}

#Route table association

resource "aws_route_table_association" "devAss1" {
  subnet_id      = aws_subnet.devsub1.id
  route_table_id = aws_route_table.devRt.id
}

resource "aws_route_table_association" "devass2" {
  subnet_id      = aws_subnet.devsub2.id
  route_table_id = aws_route_table.devRt.id
}

resource "aws_route_table_association" "devAss3" {
  subnet_id      = aws_subnet.devsub3.id
  route_table_id = aws_route_table.devRt.id
}

# security Group

resource "aws_security_group" "devSec" {
    name = "Devops_Sec"
    vpc_id = aws_vpc.Devops.id

    ingress {

        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {

        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_key_pair" "devkey" {

    key_name = "Devops_key"
    public_key = file("devkey.pub")
  
}

resource "aws_instance" "devIns" {
  
  ami = "ami-019715e0d74f695be"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.devsub1.id
  key_name = aws_key_pair.devkey.id
  vpc_security_group_ids = [aws_security_group.devSec.id]
  user_data = file("dev.sh")

  tags = {
    name = "Devops_Instance"
  }
}

output "public_ip" {
    value = aws_instance.devIns.public_ip
  
}

