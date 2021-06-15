sudo yum update

sudo setenforce 0

sudo swapoff -a


sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF


sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

cd /usr/bin
sudo rm kubelet kubeadm kubectl
sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubelet; \
sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubeadm; \
sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubectl
chmod +x kubeadm kubectl kubelet

sudo systemctl enable kubelet && systemctl start kubelet