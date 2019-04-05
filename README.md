# DevOps playground hands on with container orchestration using Docker Swarm and kubernetes

## Before we begin
Our workshops will help you to understand the basics of the container orchestration tools. It will be a ~60 minutes hands on session which should give you enough understanding to further explore one of the tools (or both) with a little help from the documentation.

If you see ```<someting>``` formatted this way It either require an input from you or refers to the output specific to your environment.

You will have two instances, which will be initially configured in the same way. During the workshops We will configure one of your instances as a master/manager, and the second will be a worker. We will be performing operations on both of them during this session so please follow the instructions carefully.

## Prerequisites
On both instances You have ```docker```, ```kubeadm```, ```kubectl``` and ```kubelet``` installed.
Installation is specific for different OSes. The instructions can be found below:
- [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://docs.docker.com/install/)

## Agenda
The hands-on session will be divided to four parts:
- [Deploy web application as standalone container](docs/standalone.md):
  - We will create a docker image containing simple web application using Dockerfile
  - We will run the container using previously created images
  - We will investigate and access our deployment
- [Deploy and use load-balancer](docs/lb.md):
  - We will create loda-balancer configuration
  - We will run the container using official haproxy images
  - We will mount our configuration as a volume
  - We will access our application through the load-balncer
- [Deploy application on the Swarm cluster](docs/swarm.md):
  - We will initialise Swarm cluster and add worker node
  - We will deploy and scale our application
  - We will simulate the failure of one the nodes
  - We will "drain" one of the nodes to see how routing mesh works
- [Deploy application on the Kubernetes cluster](docs/k8s.md):
  - We will initialise the Kubernetes cluster
  - We will deploy our application to the Kubernetes cluster
  - We will expose our service using load-balancer resource
  - We will scale our application and investigate its behaviour

## What skills/capabilities you will have after the workshop:
- You will be able to containerise and deploy an application
- You will be able to set up Docker Swarm and Kubernetes cluster
- You will be able to deploy your applications using orchestration tools
