#!/usr/bin/bash

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

ok() { green OK ; }
fail() { red "ERR\nFAIL" ; exit 2 ; }

check() { echo -n "$1 ... "; eval "$2" && ok || fail ; }


check "VM is running" "( kubectl get vm testvm -o jsonpath='{.status.phase}' ) | grep -q Running"
check "VM API is present" "kubectl api-versions | grep -q kubevirt.io"
green PASS
