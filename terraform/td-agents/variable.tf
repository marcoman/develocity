variable "aws-profile" {
    description = "The name of the aws profile to use"
    type = string
    default = null
}

variable "td-ami" {
    description = "The ami for our instance"
    type = string
    default = "ami-0bb84b8ffd87024d8"
}

variable "td-key-name" {
    description = "The name of the keypair for the instances"
    type = string
}

variable "td-instance-type" {
    description = "The instance type of our TD fleet"
    type = string
    default = "t2.micro"
}

variable "td-cidr-ingress" {
    description = "The list of CIDRS to access our instance via SSH"
    type = string
}

variable "td-cidr-egress" {
    description = "The list of CIDRS to grant our instance external access."
    type = string
}

variable "main-vpc-id" {
    description = "The primary VPC ID in your instance, assuming we are not provisioning one."
    type = string
}

variable "agent-key" {
    description = "This is the Develocity TD agent key"
    type = string
}

output "td_agent_address" {
    value = aws_instance.td_agents.public_dns
}
