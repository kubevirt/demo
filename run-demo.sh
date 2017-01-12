#!/usr/bin/bash

IMAGE=${1:-kubevirt-demo.img}

[[ -z "$IMAGE" ]] && { echo "No image given." ; exit 1 ; }

qemu-system-x86_64 --machine q35 \
        --cpu host --enable-kvm \
        --nographic -m 2048 -smp 4 \
        -net nic \
        -net user,hostfwd=:127.0.0.1:9091-:9090,hostfwd=:127.0.0.1:16510-:16509 \
        $QEMU_APPEND ${1:-kubevirt-demo.img}

