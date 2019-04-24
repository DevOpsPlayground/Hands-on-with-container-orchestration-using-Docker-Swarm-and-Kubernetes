## Kubernetes
[Home](../README.md) | [Deploy web application as standalone container](standalone.md) | [Deploy and use load-balancer](lb.md) | [Deploy application on the Swarm cluster](swarm.md)

## Lets move to the master node
First, We need to initialise the cluster with:
```bash
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

Next step is to apply flannel, our container network interface
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
Now if type
```bash
kubectl get nodes
```
You should see:
```
NAME               STATUS   ROLES    AGE   VERSION
<hostname>         Ready    master   21s   v1.13.4  
```
## Lets move to the worker node
On your second instance you need to execute the joining command which was provided when you initialised the cluster which will look like:
```bash
sudo kubeadm join <master-node>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```
## Lets move to the master node
If you cleared your terminal and did note the command you can create new token on the master node with:
```bash
kubeadm token create --print-join-command
```
Now We can deploy our service (our master node is not schedulable by default so our deployment will take place on our only worker node). Lets describe the deployment. There is a ```.yml``` file prepared for us. Lets go to our ```k8s``` directory by typing:
```bash
cd k8s
```
Now lets see what We have there. It should be ```deployment.yml``` file waiting for us, lets have a look on it by typing:
```bash
vim deployment.yml
```
Our deployment file should look like.
```yml
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
```bash
kubectl create -f deployment.yml
```
Our deployment will only be available inside our cluster for now so We need to expose it. Time to create service which will make our deployment available. In our directory you should find ```service.yml``` file, lets have a look on it:
```bash
vim service.yml
```
It should look like:
```yml
apiVersion: v1
kind: Service
metadata:
  name: hello-internet
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: NodePort
```
And now lets apply our configuration by typing
```bash
kubectl create -f service.yml
```
We should see it when typing
```bash
kubectl get services
```
and We can access our app by typing ```<worker-address>:<service-port>``` in the browser.
``

Now lets type
```bash
kubectl describe service hello-internet
```
We should see that our service is redirecting the traffic to the endpoints  which should match our pod ips. We can compare them by running that by running
```bash
kubectl get pods -o wide
```

Now lets scale the service by editing number of replicas in our ```deployment.yml``` file and applying changes with
Lets type
```bash
vim deployment.yml
```
And change the number of replicas to ```3``` and apply the changes with:
```bash
kubectl apply -f deployment.yml
```
Lets have look on our service again by typing:
```bash
kubectl describe service hello-internet
```
We should see another endpoint added to the list We have seen before. Now We can also go to our web browser and type ```<worker-address>:<service-port>``` again and refresh the page a few times.
##### Congratulations! - That was the last part of the workshops. It is time for Q&A now. If You will some questions We will not have time to answer just <a href="mailto:ppilecki@icloud.com?subject=DevOps Playground&body=Hi Patrick, I have just finished your workshop and I would like to ask">email</a> me :)
