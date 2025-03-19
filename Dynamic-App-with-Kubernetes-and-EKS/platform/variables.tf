# environment variables
variable "region" {
  description = "region to create resources"
  type        = string
}

variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

# vpc variables
variable "vpc_cidr" {
  description = "vpc cidr block"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "public subnet az1 cidr block"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "public subnet az2 cidr block"
  type        = string
}

variable "private_app_subnet_az1_cidr" {
  description = "private app subnet az1 cidr block"
  type        = string
}

variable "private_app_subnet_az2_cidr" {
  description = "private app subnet az2 cidr block"
  type        = string
}

variable "data_subnet_az1_cidr" {
  description = "private app subnet az1 cidr block"
  type        = string
}

variable "data_subnet_az2_cidr" {
  description = "private app subnet az2 cidr block"
  type        = string
}

# IAM variable
variable "aws_user_name" {
  description = "AWS user name"
  type        = string
}

# Database Variables
variable "db_username" {
  description = "Username for the RDS PostgreSQL instance"
  type        = string
}

# route53 variables
variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "alternative_names" {
  description = "sub domain name"
  type        = string
}

variable "record_name" {
  description = "sub domain name"
  type        = string
}

# SNS variables
variable "email" {
  description = "Email for receiving sns alerts"
  type        = string
}