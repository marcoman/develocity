# Overview

This folder contains the terrform for a Develocity TD agent deployment on Amazon ECS.  Tthis is a proof of concept.

The source materials are at the following link:

https://docs.gradle.com/develocity/test-distribution-agent/

This documentation tells you how to run a `java -jar` command as well as a `docker run` command.  In this small repository, I use the docker commands to create an example of how to deploy agents to ECS.

NOTE: when you deploy to ECS in this example, you do not benefit from Develocity managing your autoscaling for you.  Ideally, we would build additional logic to create more agents in response to demand.  Add that to the TODO list.


