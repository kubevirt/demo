#!/bin/bash

# Can be latest
MINIKUBE_TAG=v0.16.0

LOCALBIN=$HOME/.local/bin
export PATH=$LOCALBIN:$PATH

TMPD=/var/tmp/kubevirt-demo

die() { echo "ERR: $@" >&2 ; exit 2 ; }
has_bin() { which $1 2>&- ; }
ask_to() { $@ ; }

setup_minikube() {
  # From https://github.com/kubernetes/minikube/releases
  has_bin docker-machine-driver-kvm || err "Please install the docker kvm driver: https://github.com/kubernetes/minikube/blob/master/DRIVERS.md#kvm-driver"

  echo "Setting up minikube"
  mkdir -p $LOCALBIN
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_TAG}/minikube-linux-amd64
  chmod +x minikube
  mv minikube ${LOCALBIN}/minikube
}

deploy_kubevirt() {
  local OP=create
  echo "# Deploying KubeVirt"
  mkdir -p $TMPD
  pushd $TMPD
  [[ -d kubevirt ]] || git clone https://github.com/kubevirt/kubevirt.git
  _op_manifests
}

undeploy_kubevirt() {
  local OP=delete
  _op_manifests
}

_op_manifests() {
  local GIT_TAG=${GIT_TAG:-master}
  local DOCKER_TAG=${GIT_TAG/master/latest}

  cd $TMPD/kubevirt
  git pull
  git reset --hard $GIT_TAG

  pushd manifests
    # Fill in templates
    local MASTER_IP=$(minikube ip)
    local DOCKER_PREFIX=kubevirt
    local DOCKER_TAG=${DOCKER_TAG}
    for TPL in *.yaml.in; do
       # FIXME Also: Update the connection string for libvirtd
       sed -e "s/{{ master_ip }}/$MASTER_IP/g" \
           -e "s/{{ docker_prefix }}/$DOCKER_PREFIX/g" \
           -e "s/{{ docker_tag }}/$DOCKER_TAG/g" \
           -e "s#qemu+tcp://minikube.libvirtd.default.svc.cluster.local/system"#"  \
           $TPL > ${TPL%.in}
    done
  popd

  # Deploying
  for M in manifests/*.yaml images/libvirtd/libvirtd-ds.yaml; do
    echo $M
    kubectl $OP -f $M
  done

  sed -e "s/master/$(hostname)/" cluster/vm.json | kubectl $OP -f -

  echo "# KubeVirt is ready."
}

main() {
  has_bin minikube || ask_to setup_minikube
  has_bin minikube || die "Please install minikube"
  minikube start || :
  minikube status || die "Please start minikube"

  case $1 in
    undeploy) undeploy_kubevirt ;;
    deploy|*) deploy_kubevirt ;;
  esac
}

main

# vim: et ts=2
