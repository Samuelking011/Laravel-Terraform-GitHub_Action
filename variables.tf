# variables.tf

variable "aws_region" {
    description = "The AWS region things are created in"
    default = "us-east-1"
}

variable "app_name" {
    type    = string
    default = "sammy-ecs"
}

variable "app_env" {
    type    = string
    default = "staging"
}

variable "vpc_cidr" {
    description = "IP address range to use in VPC"
    default = "172.16.0.0/16"
}

variable "az_count" {
    description = "Number of Availability zones"
    default     = "3"
}

variable "subnet_count" {
    description = "Number of subnets"
    default     = "3"
}