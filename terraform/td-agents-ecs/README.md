# Overview

This folder contains the terrform for a Develocity TD agent deployment on Amazon ECS.  This is a proof of concept to explore what is possible.  This is not a production-ready solution.

The source materials are at the following link:

https://docs.gradle.com/develocity/test-distribution-agent/

The Develocity documentation offers 3 best options:
- Run a `java -jar` command
- Run a `docker run` command
- Use Kubernetes

This Amazon Elastic Container Service example is something you would do to show the feasibility of deploying to ECS.  The inputs are driven by your AWS keys (I use envvars), and input variables you would probably include in a `variables.tfvars` file.  Mine has this structure:

```
td-cidr-ingress             = "0.0.0.0/0"
td-cidr-egress              = "0.0.0.0/0"
td-key-name                 = "the name of your AWS EC2 keypair"
main-vpc-id                 = "This is the ID of an existing VPC you wish to re-use.  For example: vpc-1234567890abcdefa"
aws-profile                 = "not used.  The name of the AWS configuration profile on your system."
develocity-server           = "the URL to your Develocity Server in the form of https://my-develocity-server.com"
develocity-registration-key = "This is the Develocity registration key you get when you create a new Agent Pool"
develocity-td-pool          = "This is the Agent Pool ID for the registration key above"

```

# Caveats and/or TODO

I have not yet solved how to autoscale the ECS deployment.  This means we manually configure the desired count.  This would be an interesting next-step.

I don't have an answer for how to provide health status information.  The Develocity Test Distribution agent is not a web service, so we'll need something else to add that capability.

