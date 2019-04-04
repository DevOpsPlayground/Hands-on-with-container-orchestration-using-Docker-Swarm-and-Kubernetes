# DevOps playground hands on with container orchestration using Docker Swarm and kubernetes

## Before we begin
This tutorial will help you to understand the basics of the container orchestration tools. It will be a ~60 minutes hands on session which should give you enough understanding to further explore one of the tools (or both) with a little help from the documentation. If you see ```<someting>``` formatted this way It either require an input from you or refers to the output specific to your environment. You will have two instances, which will be initially configured in the same way. During the workshops We will configure your first instance will as a master/manager, and the second will be a worker/node. We will have to switch instances during this session so please follow the instructions carefully.

On both instances You have docker, kubeadm and kubelet installed.
Installation is specific for different OSes. The instructions can be found below:
- [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://docs.docker.com/install/)

[Deploy web application as standalone container](docs/standalone.md) | [Use load-balancer](docs/lb.md) | [Deploy application on the Swarm cluster](docs/swarm.md) | [Deploy application on the Kubernetes cluster](docs/k8s.md)
