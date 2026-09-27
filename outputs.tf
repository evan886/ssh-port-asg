output "vpc_id" {
  value = aws_vpc.lab.id
}

output "security_group_id" {
  value = aws_security_group.ssh.id
}

output "asg_name" {
  value = aws_autoscaling_group.lab.name
}

output "sftp_nlb_dns_name" {
  value = aws_lb.sftp.dns_name
}

output "sftp_domain" {
  value = var.sftp_domain
}

output "sftp_username" {
  value = var.sftp_username
}
