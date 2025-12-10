#!/bin/bash

#Update your existing packages:
sudo apt update
#Install a prerequisite package that allows apt to utilize HTTPS:
sudo apt-get install apt-transport-https ca-certificates curl gpg
sudo install -m 0755 -d /etc/apt/keyrings
#Add GPG key for the official Docker repo to the Ubuntu system:
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
#Add the Docker repo to APT sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


#Update the database with the Docker packages from the added repo:
sudo apt-get update
#Install Docker software:
sudo apt install -y containerd.io docker-ce docker-ce-cli
#Docker should now be installed, the daemon started, and the process enabled to start on boot. To verify:
sudo systemctl status docker
#Make the docker enable to start automatic when reboot the machine:
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl enable --now containerd
#Add user to docker Groups:
sudo usermod -aG docker ${USER}
#In AWS ec2 the user would be ubuntu
#sudo usermod -aG docker ubuntu
#Install CNI Plugin
wget https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz
#Modify containerd Configuration for systemd Support
sudo mkdir -p /etc/containerd
sudo containerd config default | tee /etc/containerd/config.toml
sudo vim /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
#Disable swap memory (if running) on both the nodes and master:
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
#Install selinux (in all Machine):
sudo apt install selinux-utils
#Disable selinux (in all Machine):
setenforce 0
#Enable IP forwarding temporarily:
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
#Enable IP forwarding permanently:
sudo sh -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
#Apply the changes:
sudo sysctl -p
#Validate Containerd
sudo crictl info
#Validate Containerd
cat /proc/sys/net/ipv4/ip_forward

#Give a unique hostname for all machines:
sudo hostnamectl set-hostname master #### master change every machine or node i wanna create



free -m
#Update your existing packages:
sudo apt-get update
#Install packages needed to use the Kubernetes apt repository:
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
#Download the public signing key for the Kubernetes package repositories.
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#Add Kubernetes Repository:
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
#Update your existing packages:
sudo apt-get update -y
#Install Kubeadm:
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
#Enable the kubelet service:
sudo systemctl enable --now kubelet
#Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter
#Update Iptables Settings
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
#Configure persistent loading of modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
#Reload sysctl
sudo sysctl --system
#Start and enable Services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo systemctl enable kubelet

