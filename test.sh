#!/usr/bin/bash

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

ok() { green OK ; }
fail() { red "ERR\nFAIL" ; exit 2 ; }

check() { echo -n "$1 ... "; eval "$2" && ok || fail ; }


check_readme_version() {
  bash -n run-demo.sh || die "demo has syntax errors"
  eval "$(grep "export GIT_TAG" run-demo.sh)"
  grep -q $GIT_TAG README.md
}

check_websocket() {
  local IP=$(minikube ip) ;
  curl -s -i -N -H "Connection: Upgrade" \
  http://$IP:8184/apis/kubevirt.io/v1alpha1/namespaces/default/vms/testvm/console | grep -q "Sec-Websocket-Version: 13" 
}


check "README contains correct version" "check_readme_version"
check "VM is running" "( kubectl get vm testvm -o jsonpath='{.status.phase}' ) | grep -q Running"
check "VM serial console works" "check_websocket"


green PASS
