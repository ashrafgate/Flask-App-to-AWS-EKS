variable "vpc_cidr" {}
variable "public_subnet_cidrs" {}

variable "private_subnet_cidrs" {}

variable "public_key_path" {
  description = "Path to the public SSH key file (.pub)"
  type        = string
}


variable "repository_name" {}
variable "name" {
  default = "myapp"
}
variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}
/*
variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS worker nodes"
}
*/
variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired number of worker nodes"
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum number of worker nodes"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of worker nodes"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t2.micro"]
  description = "List of instance types for worker nodes"
}

variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = "AMI type for worker nodes"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

