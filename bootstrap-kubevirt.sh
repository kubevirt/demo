#!/usr/bin/bash

#set -e

DOCKER_TAG=${FROM_DOCKER_TAG:-latest}

setup_kubernetes() {
  echo "# Setting up Kubernetes"

  setenforce 0
  sed -i "s/^SELINUX=.*/SELINUX=permissive/" /etc/selinux/config
  
  systemctl --now disable firewalld.service
  
  #
  # From http://kubernetes.io/docs/getting-started-guides/kubeadm/
  #
  
  #
  # (1/4) Deps
  #
  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
  setenforce 0
  yum install -y docker kubelet kubeadm kubectl kubernetes-cni
  systemctl enable docker && systemctl start docker
  systemctl enable kubelet && systemctl start kubelet
  
  # FIXME If we don't do this, then we see a lot of mount msgs
  echo 2 > /proc/sys/kernel/printk

  #
  # (2/4) Init
  #
  kubeadm init --pod-network-cidr=10.42.0.0/16 --token abcdef.1234567890123456 --use-kubernetes-version v1.4.5
  
  # Allow scheduling pods on master
  # Ignore retval because it might not be dedicated
  kubectl -s 127.0.0.1:8080 taint nodes --all dedicated- || :
  
  # Supress some messages
  echo -e "#/bin/bash\necho 2 > /proc/sys/kernel/printk" > /etc/rc.d/rc.local
  chmod a+x /etc/rc.d/rc.local
  /etc/rc.d/rc.local

  #
  # (3/4) Add a mandatory network addon
  #
  # https://www.weave.works/docs/net/latest/kube-addon/
  kubectl apply -f https://git.io/weave-kube

  echo "# Kubernetes is ready."
}

install_cockpit() {
  yum install -y cockpit cockpit-kubernetes
  systemctl enable --now cockpit.socket
  echo "# Cockpit is installed"
}

deploy_kubevirt() {
  echo "# Deploying KubeVirt"
  yum install -y git
  git clone https://github.com/kubevirt/kubevirt.git
  pushd kubevirt/manifests
    # Fill in templates
    local MASTER_IP=$(ip route show to 0.0.0.0/0 | cut -d " " -f3)
    local DOCKER_PREFIX=kubevirt
    local DOCKER_TAG=${DOCKER_TAG:-latest}
    for TPL in *.yaml.in; do
       # FIXME Also: Update the connection string for libvirtd
       sed -e "s/{{ master_ip }}/$MASTER_IP/g" \
           -e "s/{{ docker_prefix }}/$DOCKER_PREFIX/g" \
           -e "s/{{ docker_tag }}/$DOCKER_TAG/g" \
           -e "s#qemu:///system#qemu+tcp://127.0.0.1/system#"  \
           $TPL > ${TPL%.in}
    done

    # Pre-pulling images for offline usage
    local USED_IMAGES=$(egrep -oh "$DOCKER_PREFIX/.*:$DOCKER_TAG" *.yaml)
    for UI in $USED_IMAGES; do
      docker pull $UI &
    done

    wait # for the pulls to complete
  popd

  cd kubevirt

  sed -e "s/master/$(hostname)/" cluster/vm.json > /vm.json

  # Deploying
  for M in manifests/*.yaml images/libvirtd/libvirtd-ds.yaml; do
    kubectl create -f $M
  done

  echo "# KubeVirt is ready."
}

setup_kubernetes
deploy_kubevirt
install_cockpit

touch /done

#init 0
