terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.8.3"
}

locals {
  common_tags = {
    created-by   = "Marco Morales"
    created-on   = formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())
    created-for  = "Marco Morales"
    created-with = "terraform"
  }
  ingress_cidrs = var.td-cidr-ingress
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "pse_cluster" {
  name = "pse-td-agent-cluster" # Name your cluster here
}

resource "aws_security_group" "allow_td" {
  description = "Specify what is allowed on a TD Agent"
  name        = "allow_td"
  vpc_id      = var.main-vpc-id

  tags = merge(
    local.common_tags,
    {
      "Name" = "allow_td"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_td.id
  cidr_ipv4         = var.td-cidr-ingress
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
  security_group_id = aws_security_group.allow_td.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.td-cidr-egress
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "td-agent-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.pse_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "td_agent" {
  family                   = "develocity-td-agent-tf"
  network_mode             = "awsvpc"
  execution_role_arn       = "arn:aws:iam::112104134845:role/ecsTaskExecutionRole"
  cpu                      = "1024"
  memory                   = "3072"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "td-ecs-agent"
    }
  )
  container_definitions = jsonencode([
    {
      name      = "develocity-test-distribution-agent"
      image     = "gradle/develocity-test-distribution-agent:3.0.1"
      cpu       = 0
      memory    = 3072
      essential = true
      portMappings = [
        {
          name          = "develocity-td-agent-80-tcp"
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        },
        {
          name          = "develocity-td-agent-443-tcp"
          containerPort = 443
          hostPort      = 443
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "TEST_DISTRIBUTION_AGENT_POOL"
          value = "${var.develocity-td-pool}"
        },
        {
          name  = "TEST_DISTRIBUTION_AGENT_SERVER"
          value = "https://develocity-field.gradle.com"
        },
        {
          name  = "TEST_DISTRIBUTION_AGENT_REGISTRATION_KEY"
          value = "${var.develocity-registration-key}"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name                 = "pse-td-agent"
  cluster              = aws_ecs_cluster.pse_cluster.id
  task_definition      = aws_ecs_task_definition.td_agent.arn
  desired_count        = 2
  force_new_deployment = true

  network_configuration {
    subnets         = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
    security_groups = [aws_security_group.security_group.id]
  }

  placement_constraints {
    type = "distinctInstance"
  }
  triggers = {
    redeployment = timestamp()
  }
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "develocity-test-distribution-agent"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}
