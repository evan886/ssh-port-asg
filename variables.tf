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

variable "sftp_username" {
  description = "SFTP username"
  type        = string
  default     = "sftpuser"
}

variable "sftp_domain" {
  description = "SFTP DNS name"
  type        = string
  default     = "sftp.linuxsa.org"
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
  default     = "sftp.linuxsa.org"
}