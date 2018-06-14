#!/usr/bin/bash

set -e

K6T_VER=$1

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

PASS() { green PASS ; }

condTravisFold() {
  [[ -n "$TRAVIS" ]] && echo "travis_fold:start:SCRIPT folding starts" || :
  eval "$@"
  [[ -n "$TRAVIS" ]] && echo "travis_fold:end:SCRIPT folding ends" || :
}


k_wait_all_running() { while [[ "$(kubectl get $1 --all-namespaces --field-selector=status.phase!=Running | wc -l)" -gt 1 ]]; do kubectl get $1 --all-namespaces ; sleep 6; done ; }

{
  set -xe

  kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v$K6T_VER/kubevirt.yaml ;

  kubectl api-versions | grep kubevirt.io

  condTravisFold k_wait_all_running pods

  kubectl apply -f manifests/vm.yaml

  kubectl get vm testvm

  kubectl patch virtualmachine testvm --type merge -p '{"spec":{"running":true}}'

  condTravisFold k_wait_all_running pods

  # Some additional time to schedule the VM
  sleep 30

  kubectl get vmis testvm -o yaml
  kubectl get vmis testvm -o jsonpath='{.status.phase}' | grep Running

  kubectl get vmis testvm -o yaml | grep 'presets-applied'

  set +xe
}

#curl -Lo virtctl https://github.com/kubevirt/kubevirt/releases/download/v$K6T_VER/virtctl-v$K6T_VER-linux-amd64 && chmod +x virtctl && sudo mv virtctl /usr/local/bin

PASS
