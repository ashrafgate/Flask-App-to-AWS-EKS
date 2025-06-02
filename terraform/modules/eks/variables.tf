variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EKS nodes"
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired number of worker nodes"
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Max number of worker nodes"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Min number of worker nodes"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "EC2 instance types for worker nodes"
}

variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = "AMI type for nodes"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
