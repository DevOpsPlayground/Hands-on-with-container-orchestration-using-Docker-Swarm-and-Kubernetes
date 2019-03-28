# DevOps playground hands on with container orchestration using Docker Swarm and kubernetes
## Before we begin
This tutorial will help you to understand the basics of the container orchestration tools. It will be a ~60 minutes hands on session which should give you enough understanding to further explore one of the tools (or both) with a little help from the documentation. If you see ```<someting>``` formatted this way It either require an input from you or refers to the output specific to your environment.
On the instance We have docker, kubeadm and kubelet installed.
Installation is specific for different OSes The guide could be found:
([k8s](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
([docker](https://docs.docker.com/install/))


## Build and run the containerised app
For todays workshop I provided a web application We we will be deploying. You will find it in ```/app``` directory. Our first step will be to create and image with this application. We are going to use ```Dockerfile``` to do so. Lets create one by executing ```vim Dockerfile``` in the directory.
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
Lets build an image
```
docker build --tag <your-name>/web-app:<tag> .
```
We should be able to see it now:
```
docker image ls
```
You should see:
```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
<your-name>/web-app        <tag>               f47638dd1c0e        4 seconds ago       97.2MB
```
Now it is time to run our application:
```
docker run --name web-app --detach --publish 8080:80 <your-name>/web-app:1.0
```
You can see it from web browser by typing <host-address>:8080
Now lets run the same service on another instance.

## Loadbalance traffic to our containers with haproxy
Create haproxy.cfg
Lets move to the home directory and create a file
```
cd && mkdir haproxy
vim haproxy/haproxy.cfg
```
Config file should look like:
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
Finally run the container with load balancer
```
docker run --detach --name load-balancer --volume `pwd`/haproxy:/usr/local/etc/haproxy:ro --publish 80:80 haproxy
```
## Docker swarm
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
Now We need our second instance to join our swarm and to do so We just need to execute provided join command.

That is it - We have our cluster ready, so lets deploy our application. To deploy the application all We need to do is to issue the following command:

```
docker service create --name <service-name> --publish 80:80 --replicas 2 <your-name>/app-for-playground:<tag>
```
We can access our application by typing host address in our browser, lets do that. We can check where our containers our containers are running by executing on our master node ```docker service ps <service-name>```

We can also easily scale the service by executing:
```
docker service scale <service-name>=<number-of-replicas>
```
I hope that everything is going fine up to this point, because now It is time to break something. Lets drain our node so It will not be available in our cluster.
On the master node lets list our nodes with ```docker node ls``` and copy our worker node id and stop it with ```docker node update --availability drain <node-id>```
#### Questions:
What will happen with our service?

What will happen if We try to access the service on the address of drained node?

Now It is time to take another step, right into the Kuberenetes, but before We do so, lets remove our service with ```docker service rm <service-name>
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

Next step is to apply flannel
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
On your second instance you need to execute the joining command which was provided when you initialised the cluster which will look like:
```
sudo kubeadm join <master-node>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```
If you cleared your terminal and did note the command you can create new token with:
```
kubeadm token create --print-join-command
```
Now We can deploy our service (our master node will not be schedulable so our deployment will take place on our only worker). Lets describe the deployment by creating ```deployment.yml``` file
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
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
          image: pil3q/app-for-playground
```
Now lets type ```kubectl create -f deployment.yml```
Time to create LoadBalancer by creating ```loadbalancer.yml```
```
apiVersion: v1
kind: Service
metadata:
  labels:
    run: web-app
  name: lb
  namespace: default
spec:
  clusterIP:
  externalTrafficPolicy: Cluster
  ports:
  - nodePort:
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: web-app
  type: LoadBalancer
```
And now lets apply our configuration by typing ```kubectl create -f LoadBalancer.yml```
We can see it when typing ```kubectl get services``` and We can access our app by typing <worker-ip>:<port> in the browser.

Now lets type ```kubectl describe service lb```
We should see the endponints which should match our pod ips. We can check that by running ```kubectl get pods -o wide```

Now lets scale the service by editing number of replicas in our deployment.yml file and applying changes with ```kubectl apply -f deployment.yml```

#### Questions:
What will happen with our service?
How our loadbalncer will be set up?
