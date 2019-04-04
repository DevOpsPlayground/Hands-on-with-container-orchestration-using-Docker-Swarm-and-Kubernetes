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
