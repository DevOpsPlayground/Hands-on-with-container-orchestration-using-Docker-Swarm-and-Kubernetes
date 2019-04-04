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
