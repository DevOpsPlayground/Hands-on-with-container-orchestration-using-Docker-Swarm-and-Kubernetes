#!/bin/bash
# This script still requires user to be created on the hostname, please replace or provide ${username} 
# This script was used on AWS EC2 instances, to ensure fairly smooth experience it requires 4GB RAM so choose t2/3.medium or equivalent or assign 4GB per node if using locally with i.e VirtualBox
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl tree

echo "Adding ${username} user to sudoers"
sudo tee /etc/sudoers.d/${username} > /dev/null <<"EOF"
${username} ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${username}
sudo usermod -a -G sudo ${username}
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

#DOCKER
curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -a -G docker ${username}
sudo systemctl enable docker

#K8S
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/tmp/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo systemctl enable kubelet
sudo kubeadm config images pull

cd /home/${username}
sudo git clone https://github.com/DevOpsPlayground/Hands-on-with-container-orchestration-using-Docker-Swarm-and-Kubernetes.git
sudo chown -R ${username} Hands-on-with-container-orchestration-using-Docker-Swarm-and-Kubernetes
