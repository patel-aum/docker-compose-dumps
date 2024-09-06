#!/bin/bash

# Update system
yum update -y

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Enable IP forwarding
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Install required packages
yum install -y yum-utils device-mapper-persistent-data lvm2

# Add Docker repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker and enable it to start at boot
systemctl start docker
systemctl enable docker

# Add Kubernetes repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install kubeadm, kubelet, and kubectl
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable kubelet service
systemctl enable kubelet && systemctl start kubelet

echo "Kubernetes worker setup complete. Please join the cluster using the kubeadm join command provided by the master."

