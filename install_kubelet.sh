#!/bin/bash

# 在 master 节点和 worker 节点都要执行

# 安装 containerd
# 参考文档如下
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

install_containerd()
{
    cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
    
    sudo modprobe overlay
    sudo modprobe br_netfilter
    
    # Setup required sysctl params, these persist across reboots.
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward              = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
    
    # Apply sysctl params without reboot
    sysctl --system
    
    # 卸载旧版本
    yum remove -y containerd.io
    
    # 设置 yum repository
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # 安装 containerd
    yum install -y containerd.io-1.4.3
    
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
	
	# 腾讯云 docker hub 镜像
    # export REGISTRY_MIRROR="https://mirror.ccs.tencentyun.com"
    # DaoCloud 镜像
    # export REGISTRY_MIRROR="http://f1361db2.m.daocloud.io"
    # 阿里云 docker hub 镜像
    # export REGISTRY_MIRROR=https://registry.cn-hangzhou.aliyuncs.com
    
    sed -i "s#k8s.gcr.io#registry.aliyuncs.com/k8sxio#g"  /etc/containerd/config.toml
    sed -i '/containerd.runtimes.runc.options/a\ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml
    sed -i "s#https://registry-1.docker.io#https://registry.cn-hangzhou.aliyuncs.com#g"  /etc/containerd/config.toml
    
    
    systemctl daemon-reload
    systemctl enable containerd
    systemctl restart containerd
    containerd --version
}

# 安装 docker
# 参考文档如下
# https://docs.docker.com/install/linux/docker-ce/centos/ 
# https://docs.docker.com/install/linux/linux-postinstall/

install_docker()
{
    # 修改 /etc/sysctl.conf
    # 如果有配置，则修改
    sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
    sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
    sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
    sed -i "s#^net.ipv6.conf.all.disable_ipv6.*#net.ipv6.conf.all.disable_ipv6=1#g"  /etc/sysctl.conf
    sed -i "s#^net.ipv6.conf.default.disable_ipv6.*#net.ipv6.conf.default.disable_ipv6=1#g"  /etc/sysctl.conf
    sed -i "s#^net.ipv6.conf.lo.disable_ipv6.*#net.ipv6.conf.lo.disable_ipv6=1#g"  /etc/sysctl.conf
    sed -i "s#^net.ipv6.conf.all.forwarding.*#net.ipv6.conf.all.forwarding=1#g"  /etc/sysctl.conf
    # 可能没有，追加
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
    echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding = 1"  >> /etc/sysctl.conf
    # 执行命令以应用
    sysctl -p
    
    # 卸载旧版本
    yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-ce-cli \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine
    
    # 设置 yum repository
    yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    
    # 安装并启动 docker
    yum install -y docker-ce-19.03.11 docker-ce-cli-19.03.11 containerd.io-1.2.13
    
    mkdir /etc/docker || true
	
    # 腾讯云 docker hub 镜像
    # export REGISTRY_MIRROR="https://mirror.ccs.tencentyun.com"
    # DaoCloud 镜像
    # export REGISTRY_MIRROR="http://f1361db2.m.daocloud.io"
    # 阿里云 docker hub 镜像
    # export REGISTRY_MIRROR=https://registry.cn-hangzhou.aliyuncs.com
    cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://registry.cn-hangzhou.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
    
    mkdir -p /etc/systemd/system/docker.service.d
    
    # Restart Docker
    systemctl daemon-reload
    systemctl enable docker
    systemctl restart docker
    docker version
}

system_init()
{
    # 安装 nfs-utils
    # 必须先安装 nfs-utils 才能挂载 nfs 网络存储
    yum install -y nfs-utils
    yum install -y wget
    
    # 关闭 防火墙
    systemctl stop firewalld
    systemctl disable firewalld
    
    # 关闭 SeLinux
    setenforce 0
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
    
    # 关闭 swap
    swapoff -a
    yes | cp /etc/fstab /etc/fstab_bak
    cat /etc/fstab_bak |grep -v swap > /etc/fstab
    
    # 配置K8S的yum源
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
      http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
}

install_kube()
{
    # 卸载旧版本
    yum remove -y kubelet kubeadm kubectl
    
    # 安装kubelet、kubeadm、kubectl
    # 将 ${1} 替换为 kubernetes 版本号，例如 1.20.1
    yum install -y kubelet-${1} kubeadm-${1} kubectl-${1}
    

}


main()
{
    echo "    What runtime do you want to use："
    echo "        1. Docker"
    echo "        2. Containerd"
    echo ""
    read -p "Please choose your runtime(1 or 2): " choose
    
    if [[ $choose -eq 1 ]]
    then
        install_docker
        system_init
        install_kube $1
        # 重启 docker，并启动 kubelet
        systemctl daemon-reload
        systemctl restart docker
    elif [[ $choose -eq 2 ]]
    then
        install_containerd
        system_init
        install_kube $1
        crictl config runtime-endpoint /run/containerd/containerd.sock
    else
        echo "Wrong number!"
        continue
    fi
}

if [[ $1 = "" ]]
then
    echo "Please run the script with kubelet/kubectl/kubeadm version." 
    echo "bash install_kubelet.sh 1.22.3"
    exit 1
else
    kube_version=$1
fi

main $kube_version

# 重启 docker，并启动 kubelet
systemctl daemon-reload
systemctl enable kubelet && systemctl start kubelet
docker version || containerd --version
kubelet --version
