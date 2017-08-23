#!/usr/bin/bash

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }

ok() { green OK ; }
fail() { red "ERR\nFAIL" ; exit 2 ; }

check() { echo -n "$1 ... "; eval "$2" && ok || fail ; }

check "VM is running" "( kubectl get -o json vms testvm | jq .status.phase ) | grep -q Running"
# FIXME serial and spice need to be fixed.
# check "Can connect to VM serial console" "./virtctl console testvm -d serial0 & sleep 3 ; kill $$?"

green PASS
