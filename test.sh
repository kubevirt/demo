#!/usr/bin/bash

set -e

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

PASS() { green PASS ; }

condTravisFold() {
  [[ -n "$TRAVIS" ]] && echo "travis_fold:start:SCRIPT folding starts" || :
  eval "$@"
  [[ -n "$TRAVIS" ]] && echo "travis_fold:end:SCRIPT folding ends" || :
}

timeout_while() { timeout $1 sh -c "while true; do $2 && break || : ; sleep 1 ; done" ; }
k_wait_all_running() { bash ci/wait-pods-ok; }

{
  set -xe

  kubectl apply -f manifests/vm.yaml

  kubectl get vm testvm

  kubectl patch virtualmachine testvm --type merge -p '{"spec":{"running":true}}'
  timeout_while 30s "kubectl get vmis | grep testvm"

  condTravisFold k_wait_all_running

  # Some additional time to schedule the VM
  kubectl describe vmis testvm
  timeout_while 1m "kubectl get vmis testvm -o jsonpath='{.status.phase}' | grep Running"

  set +xe
}

PASS
