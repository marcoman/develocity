terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = ">= 5.0"
      }
    }
    required_version = ">= 1.8.3"
}

data "aws_ami" "amazon2" {
    most_recent = true
    filter {
        name = "name"
        # values = ["amzn2-ami-hvm-*-x86_64-ebs"]
        values = ["al2023-ami-2023*-x86_64"]
    }
    owners = ["amazon"]
}

locals {
    common_tags = {
        created-by = "Marco Morales"
        created-on = formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())
        created-for = "Marco Morales"
    }
    ingress_cidrs = var.td-cidr-ingress
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "td_agents" {
    ami = data.aws_ami.amazon2.id
    associate_public_ip_address = true
    key_name = var.td-key-name
    instance_type = var.td-instance-type
    vpc_security_group_ids = [aws_security_group.allow_td.id]

    root_block_device {
      encrypted = true
      volume_size = 20
    }

    user_data = <<-EOF
    #!/bin/bash
    until ping -c1 8.8.8.8 &>/dev/null; do :; done
    echo "YUM Update"
    yum clean all
    yum update -y --skip-broken

    echo "INSTALL: YUM Java 17"
    yum -y install java-17-amazon-corretto-devel

    # Java 21 is not available for AWS Linux 2.
    echo "INSTALL: YUM Java 21"
    yum -y install java-21-amazon-corretto-devel

    echo "INSTALL: Get Develocity Agent"
    wget https://docs.gradle.com/develocity/test-distribution-agent/develocity-jar/develocity-test-distribution-agent-3.0.1.jar -O td-agent.jar
    chown ec2-user td-agent.jar
    mv td-agent.jar /home/ec2-user

    echo "INSTALL: Setup envvars"
    export JDK17=/usr/lib/jvm/java-17-amazon-corretto.x86_64
    export JDK21=/usr/lib/jvm/java-21-amazon-corretto
    /usr/lib/jvm/java-21-amazon-corretto/bin/java -Xms64m -Xmx64m -XX:MaxMetaspaceSize=64m \
    -jar /home/ec2-user/td-agent.jar \
    --server ${var.develocity-server} \
    --registration-key ${var.develocity-registration-key} \
    --pool ${var.develocity-td-pool}
    EOF

    tags = merge (
        local.common_tags,
        {
            "Name" = "td-agent"
        }
    )
}

resource "aws_security_group" "allow_td" {
    description = "Specify what is allowed on a TD Agent"
    name = "allow_td"
    vpc_id = var.main-vpc-id

    tags = merge (
        local.common_tags,
        {
            "Name" = "allow_td"
        }
    )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
    security_group_id = aws_security_group.allow_td.id
    cidr_ipv4 = var.td-cidr-ingress
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
    security_group_id = aws_security_group.allow_td.id
    from_port = 0
    to_port = 0
    ip_protocol = "-1"
    cidr_ipv4 = var.td-cidr-egress
}
