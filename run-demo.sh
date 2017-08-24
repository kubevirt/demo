#!/bin/bash

export GIT_TAG="v0.0.1-alpha.6"

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

die() { red "ERR: $@" >&2 ; exit 2 ; }
silent() { "$@" > /dev/null 2>&1 ; }
has_bin() { silent which $1 ; }
title() { bold "$@" ; }
par() { echo -e "- $@" ; }
parn() { echo -en "- $@ ... " ; }
ok() { green "${@:-OK}" ; }

pushd() { command pushd "$@" >/dev/null ; }
popd() { command popd "$@" >/dev/null ; }

LOCALBIN=$HOME/.local/bin
export PATH=$LOCALBIN:$PATH

TMPD=/var/tmp/kubevirt-demo
PLUGIN_PATH="$HOME/.kube/plugins/virtctl"

check_kubectl() {
  parn "Checking kubectl version"
  local CTLVER=$(kubectl version --short --client)
  egrep -q "1.[78]" <<< $CTLVER || \
    die "kubectl needs to be 1.7 or higher: $CTLVER"
  ok
}

check_for_minikube() {
  parn "Checking for minikube"
  has_bin minikube || \
    die "minikube not found. Please install minikube, see
https://github.com/kubernetes/minikube for details."
  ( minikube status | grep -qsi stopped ) && \
    die "minikube is installed but not started. Please start minikube."
  ok
}

deploy_kubevirt() {
  parn "Checking out KubeVirt"
  {
    mkdir -p $TMPD
    pushd $TMPD
    [[ -d kubevirt ]] || git clone https://github.com/kubevirt/kubevirt.git
  }
  ok
  par "Deploying manifests - this can take several minutes!"
  {
    _op_manifests apply
    par "Waiting for the cluster to be ready ..."
    kubectl get pods -w | while read LINE 
    do
      echo -n "  Cluster changed, checking if KubeVirt is ready ... "
      if ! kubectl get pods | grep -qs ContainerCreating; then
        ok "Yes!"
        ok "KubeVirt is now ready."
        echo "Optional, register the virt plugin for VM access:"
        echo "  $0 plug"
        echo "Try: $ kubectl get vms"
        kill $(pidof -- kubectl get pods -w)
        break
      fi
      echo "Not yet."
    done
  }
}

undeploy_kubevirt() {
  parn "Removing KubeVirt from minikube"
  _op_manifests delete
  ok
}

_op_manifests() {
  local OP=$1
  local GIT_TAG=${GIT_TAG:-master}
  local DOCKER_TAG=${GIT_TAG/master/latest}

  cd $TMPD/kubevirt
  silent git pull
  silent git reset --hard $GIT_TAG
  silent git clean -fdx

  pushd manifests
    # Fill in templates
    local MASTER_IP=$(minikube ip)
    local DOCKER_PREFIX=kubevirt
    local DOCKER_TAG=${DOCKER_TAG}
    local PRIMARY_NIC=eth0
    for TPL in *.yaml.in; do
       sed -e "s/{{ master_ip }}/$MASTER_IP/g" \
           -e "s/{{ docker_prefix }}/$DOCKER_PREFIX/g" \
           -e "s/{{ docker_tag }}/$DOCKER_TAG/g" \
           -e "s/{{ primary_nic }}/$PRIMARY_NIC/g" \
           -e "s#qemu.*/system#qemu+tcp://minikube/system#"  \
           -e "s#kubernetes.io/hostname:.*#kubernetes.io/hostname: minikube#" \
           $TPL > ${TPL%.in}
    done
  popd

  # Deploying
  for M in manifests/*.yaml; do
    silent kubectl $OP -f $M
  done

  [[ "$OP" != "delete" ]] && kubectl $OP -f cluster/vm.json
}


setup_kubectl_plugin() {
  local VIRTCTL="$PLUGIN_PATH/virtctl"
  parn "Fetching and registering virtctl"
  mkdir -p "$PLUGIN_PATH" || die "Failed to create plugin path"
  if [[ ! -f "$VIRTCTL" ]]; then
    curl -# -o "$VIRTCTL" \
       -L "https://github.com/kubevirt/kubevirt/releases/download/$GIT_TAG/virtctl" || \
      die "Failed to fetch plugin"
    chmod a+x "$VIRTCTL" || die "Failed to make plugin executable"
  fi

cat > "$PLUGIN_PATH/plugin.yaml" <<EOF
name: "virt"
shortDesc: "Provides virtualization related commands"
command: "$VIRTCTL"
EOF

  ( kubectl plugin 2>&1 | grep -q virt ) || die "Registration failed"
  ok
}

main() {
  title "KubeVirt (${GIT_TAG}) demo on minikube"

  case $1 in
    help) cat <<EOF
Usage: $0 [deploy|undeploy|setup-plugin]
  deploy   - (default) Deploy KubeVirt to the local minikube
  undeploy - Remove the previously deployed KubeVirt deployment
  plug     - Fetches and registers the virtctl plugin for kubectl
             (Usage: kubectl plugin virt)
  unplug   - Remove the previously installed virtctl plugin
EOF
;;
    plug)
      check_kubectl
      setup_kubectl_plugin ;;
    unplug)
      parn "Removing plugin"
      rm -rf "$PLUGIN_PATH" || die "Failed to remove plugin"
      ok
      ;;
    undeploy)
      check_kubectl ; check_for_minikube
      undeploy_kubevirt ;;
    deploy|*)
      check_kubectl ; check_for_minikube
      deploy_kubevirt ;;
  esac
}

main $@

# vim: et ts=2
