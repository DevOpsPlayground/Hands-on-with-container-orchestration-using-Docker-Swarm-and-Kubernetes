## Build and run the containerised application
[Home](../README.md) | [Deploy and use load-balancer](lb.md) | [Deploy application on the Swarm cluster](swarm.md) | [Deploy application on the Kubernetes cluster](k8s.md)

## Lets move to the master node!
For todays workshop I provided a web application We we will be deploying. You will find it in ```/app``` directory. You can move there by typing
 ```bash
 cd app
 ```
 Our first step will be to create a docker image with the application. We are going to use ```Dockerfile``` to do so. You can see that there is one in our directory already but it require your personal touch. Lets have a look on it by typing
 ```
 vim Dockerfile
 ```
Our ```Dockerfile``` should look like below:
```bash
FROM python:3.7-alpine

WORKDIR /app

COPY . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80

ENV NAME <your-name>

ENTRYPOINT ["python3.7", "app.py"]
```
Lets build an image.
```bash
docker build --tag devopspg/web-app:1.0 .
```
Lets list the local images by typing:
```bash
docker image ls
```
You should see:
```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
devopspg/web-app           1.0                 f47638dd1c0e        4 seconds ago       97.2MB
```
Now it is time to run our application:
```bash
docker run --name web-app --detach --publish 8080:80 devopspg/web-app:1.0
```
You can see it from web browser by typing ```<instance-address>:8080```

## Lets move to the worker node!
Now lets replicate the same steps on the second instance


[Next - Deploy and use load-balancer](lb.md)
