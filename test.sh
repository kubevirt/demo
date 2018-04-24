#!/usr/bin/bash

set -e

K6T_VER=$1

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

ok() { green OK ; }
FAIL() { red "ERR\nFAIL" ; [[ -f logs ]] && cat logs ; exit 2 ; }
PASS() { green PASS ; }

check() { echo -n "$1 ... "; eval "$2" > logs 2>&1 && ok || FAIL ; }

k_wait_all_running() { while [[ "$(kubectl get $1 --all-namespaces --field-selector=status.phase!=Running | wc -l)" -gt 1 ]]; do kubectl get $1 --all-namespaces ; sleep 6; done ; }


testDeploy() {
  kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v$K6T_VER/kubevirt.yaml ;
}
check "Deploying KubeVirt" testDeploy

testHasAPI() {
  kubectl api-versions | grep kubevirt.io
}
check "Has API" testHasAPI

k_wait_all_running pods

testCreateOVM() {
  kubectl apply -f manifests/vm.yaml
}
check "Can create OVM" testCreateOVM

testHasOVM() {
  kubectl get ovm testvm
}
check "Has OVM" testHasOVM

testCanLaunchVM() {
  kubectl patch offlinevirtualmachine testvm --type merge -p '{"spec":{"running":true}}'
}
check "Can launch VM from OVM" testCanLaunchVM

k_wait_all_running pods

# Some additional time to schedule the VM
sleep 30

testHasRunningVM() {
  kubectl get vms testvm -o yaml
  kubectl get vms testvm -o jsonpath='{.status.phase}' | grep Running
}
check "Has a running VM" testHasRunningVM

testHasPresetsApplied() {
  kubectl get vms testvm -o yaml | grep 'virtualmachinepreset.kubevirt.io/small'
}
check "VM has presets applied" testHasPresetsApplied

#curl -Lo virtctl https://github.com/kubevirt/kubevirt/releases/download/v$K6T_VER/virtctl-v$K6T_VER-linux-amd64 && chmod +x virtctl && sudo mv virtctl /usr/local/bin

PASS
