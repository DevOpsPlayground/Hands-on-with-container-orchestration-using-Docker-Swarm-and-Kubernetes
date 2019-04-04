# DevOps playground hands on with container orchestration using Docker Swarm and kubernetes
## Before we begin
This tutorial will help you to understand the basics of the container orchestration tools. It will be a ~60 minutes hands on session which should give you enough understanding to further explore one of the tools (or both) with a little help from the documentation. If you see ```<someting>``` formatted this way It either require an input from you or refers to the output specific to your environment. You will have two instances, which will be initially configured in the same way. During the workshops We will configure your first instance will as a master/manager, and the second will be a worker/node. We will have to switch instances during this session so please follow the instructions carefully.

On both instances You have docker, kubeadm and kubelet installed.
Installation is specific for different OSes. The guides could be found:
([k8s](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
([docker](https://docs.docker.com/install/))


## Build and run the containerised app
#### Lets move to the master node
For todays workshop I provided a web application We we will be deploying. You will find it in ```/app``` directory. You can move there by typing
 ```
 cd app
 ```
 Our first step will be to create an image with this application. We are going to use ```Dockerfile``` to do so. You can see that there is one in our directory already but it require your personal touch. Lets have a look on it by typing
 ```
 vim Dockerfile
 ```
Our dockerfile should look like:
```
FROM python:3.7-alpine

WORKDIR /app

COPY . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80

ENV NAME <your-name>

ENTRYPOINT ["python3.7", "app.py"]
```
Lets build an image.
```
docker build --tag devopspg/web-app:1.0 .
```
Lets list the local images by typing:
```
docker image ls
```
You should see:
```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
devopspg/web-app           1.0                 f47638dd1c0e        4 seconds ago       97.2MB
```
Now it is time to run our application:
```
docker run --name web-app --detach --publish 8080:80 devopspg/web-app:1.0
```
You can see it from web browser by typing <master-node>:8080

#### Lets move to the worker node
Now lets replicate the same steps on the second instance

## Loadbalance traffic to our containers with haproxy
#### Lets move to the master node
We need to create haproxy.cfg file which will contain configuration of our loadbalncer
Lets move away from ```app``` directory and move to the ```haproxy``` and create a loadbalancer configuration. We can do so by executing
```
cd ..
vim haproxy/haproxy.cfg
```
Config file is almost ready to use and should look like the one below. We need to specify our node-ips and ports to make it ready to run.
```
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
Finally run lets run the container with load balancer
```
docker run --detach --name load-balancer --volume `pwd`/haproxy:/usr/local/etc/haproxy:ro --publish 80:80 haproxy
```
Now lets type our master node address in the browser, then refresh the page a few times. You should see how traffic is directed to the different nodes/containers.

It is a glimpse of the container world without orchestration. Lets cleanup and remove the containers on both nodes by executing:
```
docker rm -f `docker ps -a -q`
```

## Docker swarm
#### Lets move to the master node
Our first step will be to initialise our swarm. We can do it by issuing the following command:
```
docker swarm init
```
In our terminal We should see:
```
Swarm initialized: current node (<node-id>) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-<token> <private-ip>:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
#### Lets move to the worker node
Now We need our second instance to join our swarm and to do so We just need to execute provided join command
```
docker swarm join --token SWMTKN-1-<token> <private-ip>:2377
```
#### Lets move to the master node
That is it - We have our cluster ready, so lets deploy our application. To deploy the application all We need to do is to issue the following command:

```
docker service create --name web-app --publish 80:80 --replicas 2 devopspg/web-app:1.0
```
We can access our application by typing host address in our browser, lets do that. We can check where our containers are running by executing on our master node
```
docker service ps web-app
```
Lets type our master node ip address in the browser and refresh the page, then type the worker address and refresh the page againg.

We can also easily scale the service by executing:
```
docker service scale web-app=3
```
#### Lets move to the worker node
Lets see the containers on our worker node by typing:
```
docker ps
```
#### Lets move to the master node
I hope that everything is going fine up to this point, because now It is time to break something. Lets drain our node so It will not be available in our cluster.
On the master node lets list our nodes with
```
docker node ls
```
and copy our worker node id and drain it with
```
docker node update --availability drain <worker-node-id>
```
#### Lets move to the worker node
Lets see the containers on our worker node again by typing:
```
docker ps
```
We shouldn't have any containers running
#### Lets move to the master node
Lets type
```
docker ps
```
on our master node this time. We should see 3 containers with our web application as the service automatically scaled on available nodes. Lets try to type our worker ip in the web browser now.

Now It is time to take another step, right into the Kuberenetes, but before We do so, lets remove our service with
```
docker service rm web-app
```
#### Lets move to the worker node
Lets clean up and leave the swarm with
```
docker swarm leave
```
#### Lets move to the master node
And lets get rid of our swarm by typing
```
docker swarm leave --force
```
We need to use ```--force``` flag on manager
## Kubernetes
Initialise the cluster with:
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
After a short while you should see this in your terminal:
```
Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Copy and past those three commands as instructed

Next step is to apply flannel, our container network configuration interface
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
Now if type
```
kubectl get nodes
```
You should see:
```
NAME               STATUS   ROLES    AGE   VERSION
<hostname>         Ready    master   21s   v1.13.4  
```
#### Lets move to the worker node
On your second instance you need to execute the joining command which was provided when you initialised the cluster which will look like:
```
sudo kubeadm join <master-node>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```
#### Lets move to the master node
If you cleared your terminal and did note the command you can create new token on the master node with:
```
kubeadm token create --print-join-command
```
Now We can deploy our service (our master node is not schedulable by default so our deployment will take place on our only worker node). Lets describe the deployment by creating ```.yml``` file. Lets go to our ```k8s``` directory by typing:
```
cd k8s
```
to see if there is something prepared for us. It should be ```deployment.yml``` file waiting for us, lets have a look on it by typing:
```
vim deployment.yml
```
Our deployment file should look like.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: web-app
          image: devopspg/web-app:1.0
```
Now lets deploy our application with:
```
kubectl create -f deployment.yml
```
Our deployment will only be available inside our cluster so we need to expose it. Time to create LoadBalancer. In our directory you should find ```loadbalancer.yml``` file, lets have a look on it:
```
vim loadbalncer.yml
```
It should look like:
```
apiVersion: v1
kind: Service
metadata:
  name: loadbalncer
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```
And now lets apply our configuration by typing
```
kubectl create -f loadbalancer.yml
```
We should see it when typing
```
kubectl get services
```
and We can access our app by typing worker address and loadbalncer port in the browser.
``

Now lets type
```
kubectl describe service lb
```
We should see that our loadbalancer is redirecting the traffic to the endpoints  which should match our pod ips. We can campare them by running that by running
```
kubectl get pods -o wide
```

Now lets scale the service by editing number of replicas in our deployment.yml file and applying changes with
Lets type
```
vim deployment.yml
```
And change the number of replicas to ```3``` and apply the changes with:
```
kubectl apply -f deployment.yml
```
Lets have look on our loadbalncer now, We should see another endpoint added to the browser there there.
