variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-east-1"
}

variable "my_ip" {
  description = "Your public IP address in CIDR notation"
  type        = string
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
  default     = "ssh-port-lab-key"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}