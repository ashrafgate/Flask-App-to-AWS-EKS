aws_region = "ap-south-1"

vpc_cidr = "10.0.0.0/16"
public_key_path = "/var/lib/jenkins/.ssh/id_rsa.pub" #"~/.ssh/id_rsa.pub"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

# This will be filled dynamically by Terraform output after initial VPC apply
# Temporarily leave it empty or comment it out if you're doing `terraform apply` in multiple stages
#private_subnet_ids = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]

cluster_name = "my-flask-cluster"
repository_name = "my-flask-repo"

desired_capacity = 2
max_size         = 3
min_size         = 1

instance_types = ["t2.micro"]

ami_type = "AL2_x86_64"

tags = {
  Environment = "production"
  Owner       = "devops-team"
}
