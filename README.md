test for    ec2  ASG  sftp 

phase 1 not nlb yet 



from 22 to 60022

0s elapsed]
╷
│ Error: deleting ELBv2 Target Group (arn:aws:elasticloadbalancing:ap-east-1:092611985600:targetgroup/sftp-port-lab-tg/c03f4afed704de27): operation error Elastic Load Balancing v2: DeleteTargetGroup, https response error StatusCode: 400, RequestID: d8927159-29ba-4b17-962a-a981800ae0e6, ResourceInUse: Target group 'arn:aws:elasticloadbalancing:ap-east-1:092611985600:targetgroup/sftp-port-lab-tg/c03f4afed704de27' is currently in use by a listener or a rule
│ 
│ 
╵
TG 已在 
 
 你现在：

terraform state show aws_lb_target_group.sftp

看到：

name = "sftp-port-lab-tg"
port = 22

说明 state 里面的这个 TG 就是 AWS 现有的那个 TG：

arn:...:targetgroup/sftp-port-lab-tg/c03f4afed704de27

所以不要再执行 terraform import。

它已经在 state 里面了。


方案 A：你就是想把 TG port 从 22 改成 60022

那就要接受：

old TG 22
   ↓
replacement
   ↓
new TG 60022

但是由于两个 TG 使用相同的：

name = "sftp-port-lab-tg"

Terraform 在 replacement 的过程中会产生名字冲突。

这种情况下比较适合：

lifecycle {
  create_before_destroy = false
}

让 Terraform 先删旧 TG，再创建新 TG。

但这里有一个很重要的问题：

你的 Listener 和 ASG 都依赖这个 TG：

NLB
 │
 ▼
Listener :60022
 │
 ▼
Target Group
 │
 ▼
ASG
 │
 ▼
EC2 :22

所以如果先删除 TG，期间 SFTP/SSH 流量会中断。

对于你现在这个实验环境，如果没有业务流量，可以这么做。

import 也没用，那如果我手工删除了 tg呢


不过你这个 Target Group 被 Listener 引用 的场景还有一个细节：false 并不代表 Terraform 一定能顺利“先删”，因为 AWS 会拒绝删除仍被 Listener 使用的 TG——这就是你刚才遇到 ResourceInUse 的原因。

asg_name = "ssh-port-lab-asg"
security_group_id = "sg-016fcd16805cd55f8"
sftp_domain = "sftp.linuxsa.org"
sftp_nlb_dns_name = "sftp-port-lab-nlb-ab7eb8ef3ee9d5db.elb.ap-east-1.amazonaws.com"
sftp_username = "sftpuser"
vpc_id = "vpc-0a29721b59f42cfb5"


****************
 
 version = "~> 6.0":约束 AWS Provider 大版本为 6.x,即 >= 6.0.0, < 7.0.0。注意 aws provider 6.x 相对 5.x 有一些破坏性变更(如一些资源参数调整)。
 
 十八、确认新 EC2
 Lt userdata 不成功
 
