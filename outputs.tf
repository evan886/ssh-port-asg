output "vpc_id" {
  value = aws_vpc.lab.id
}

output "security_group_id" {
  value = aws_security_group.ssh.id
}

output "asg_name" {
  value = aws_autoscaling_group.lab.name
}

