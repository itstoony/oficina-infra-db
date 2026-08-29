terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "oficina-terraform-state-302789973247"
    key    = "db/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "rds" {
  name        = "oficina-rds-sg"
  description = "Permite acesso ao RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "PostgreSQL"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "oficina-rds-sg"
    Project = "oficina"
  }
}

resource "aws_db_subnet_group" "oficina" {
  name       = "oficina-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name    = "oficina-db-subnet-group"
    Project = "oficina"
  }
}

resource "aws_db_instance" "oficina" {
  identifier        = "oficina-db"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.oficina.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = true
  skip_final_snapshot     = true
  backup_retention_period = 7
  deletion_protection     = false

  tags = {
    Name    = "oficina-db"
    Project = "oficina"
  }
}
