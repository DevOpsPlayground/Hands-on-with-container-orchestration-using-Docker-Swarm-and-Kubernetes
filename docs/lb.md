## Loadbalance traffic to our containers with haproxy
[Home](../README.md) | [Deploy web application as standalone container](standalone.md) | [Deploy application on the Swarm cluster](swarm.md) | [Deploy application on the Kubernetes cluster](k8s.md)
## Lets move to the master node
We need to create haproxy.cfg file which will contain configuration of our load-balncer
Lets move up from ```app``` directory and create load-balancer configuration in the ```haproxy``` directory. We can do so by executing
```bash
cd ..
vim haproxy/haproxy.cfg
```
Config file is almost ready to use and should look like the one below. We need to specify our ```<host-addresses>``` and ```<ports>``` to make it ready to run.
```bash
global
    daemon

defaults
    mode    http
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend haproxynode
    bind *:80
    mode http
    default_backend backendnodes

backend backendnodes
    balance roundrobin
    option forwardfor
    server node1 <host-address:port> check
    server node2 <host-address:port> check

```
Finally run lets run the container with the load-balancer using:
```bash
docker run --detach --name load-balancer --volume `pwd`/haproxy:/usr/local/etc/haproxy:ro --publish 80:80 haproxy
```
Now lets type our ```<master-node-address>``` in the browser, then refresh the page a few times. You should see how traffic is directed to the different nodes/containers.

It is a glimpse of the container world without orchestration. Lets cleanup and remove the containers on both nodes by executing:
```bash
docker rm -f `docker ps -a -q`
```

[Next - Deploy application on the Swarm cluster](swarm.md)
