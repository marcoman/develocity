variable "aws-profile" {
    description = "The name of the aws profile to use"
    type = string
    default = null
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

variable "develocity-server" {
    description = "The URL to our Develocity server"
    type = string
}

variable "develocity-registration-key" {
    description = "The TD registration key, passed to the -registry-key"
    type = string
}

variable "develocity-td-pool" {
    description = "The Develocity Pool identifier"
    type = string
}

output "td_agent_address" {
    value = aws_instance.td_agents.public_dns
}

