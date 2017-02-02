#!/bin/bash

IMAGE=${1:-kubevirt-demo.img}

[[ -z "$IMAGE" ]] && { echo "No image given." ; exit 1 ; }

QEMU_CMD=/usr/libexec/qemu-kvm
if [[ ! -x $QEMU_CMD ]]
then
    QEMU_CMD=qemu-system-x86_64
fi

$QEMU_CMD \
        --cpu host --machine accel=kvm:tcg \
        --nographic -m 2048 -smp 4 \
        -net nic \
        -object rng-random,id=objrng0,filename=/dev/urandom -device virtio-rng-pci,rng=objrng0 \
        -net user,hostfwd=:127.0.0.1:9091-:9090,hostfwd=:127.0.0.1:16510-:16509,hostfwd=:127.0.0.1:8002-:8001 \
        $QEMU_APPEND ${1:-kubevirt-demo.img}

