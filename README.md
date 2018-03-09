[![Build Status](https://travis-ci.org/kubevirt/demo.svg?branch=master)](https://travis-ci.org/kubevirt/demo)

# KubeVirt Demo

This demo will deploy [KubeVirt](https://www.kubevirt.io) on an existing
[minikube](https://github.com/kubernetes/minikube/) with Kubernetes 1.9 or
later.

## Quickstart

### Deploy KubeVirt

This demo assumes that [minikube](https://github.com/kubernetes/minikube/) is up and running and `kubectl` available on your system. If not, then please take a look at the guide [below](#appendix-deploying-minikube)

With minikube running, you can easily deploy KubeVirt:

```bash
$ export VERSION=v0.3.0
$ git clone https://github.com/kubevirt/demo.git
$ cd demo
$ kubectl create \
    -f https://github.com/kubevirt/kubevirt/releases/download/$VERSION/kubevirt.yaml
```

> **Note:** The initial deployment to a new minikube instance can take
> a long time, because a number of containers have to be pulled from the
> internet. Use `watch kubectl get --all-namespaces pods` to monitor the progress.

### Deploy a VirtualMachine

Once you deployed KubeVirt you are ready to launch a VM:

```bash
# Creating a virtual machine
$ kubectl apply -f manifests/vm.yaml

# After deployment you can manage VMs using the usual verbs:
$ kubectl get ovms
$ kubectl get ovms -o yaml testvm

# To start an offline VM you can use
$ kubectl patch offlinevirtualmachine testvm --type merge -p '{"spec":{"running":true}}'
$ kubectl get vms
$ kubectl get vms -o yaml testvm

# To shut it down again
$ kubectl patch offlinevirtualmachine testvm --type merge -p '{"spec":{"running":false}}'

# To delete: kubectl delete vms testvm
# To create your own: kubectl create -f $YOUR_VM_SPEC
```

### Accessing VMs (serial console & spice)

> **Note:** This requires `kubectl` from Kubernetes 1.9 or later on the client

A separate binary is provided to get quick access to the serial and graphical
ports of a VM. The tool is called `virtctl` and can be retrieved from the
release page of KubeVirt:

```bash
# Get virtctl

$ curl -L -o virtctl \
    https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-linux-amd64
$ chmod +x virtctl
```

Now you are ready to connect to the VMs:

```
# Connect to the serial console
$ ./virtctl console --kubeconfig ~/.kube/config testvm

# Connect to the graphical display
$ ./virtctl vnc --kubeconfig ~/.kube/config testvm
```

## Next steps

### User Guide

Now that KubeVirt is up an running, you can take a look at the [user guide](https://kubevirt.gitbooks.io/user-guide/) to understand how you can create and manage your own virtual machines.

### Verification

A small script is provided to do some basic sanity checking, you can use it in order to see if KubeVirtw as deployed correctly:

```
$ ./test.sh 
README contains correct version ... OK
VM is running ... OK
VM serial console works ... OK
PASS
```

## Appendix: Deploying minikube

1. If not installed, install minikube as described [here](https://github.com/kubernetes/minikube/)

   1. Install the [driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md)
   2. Download the [`minikube` binary](https://github.com/kubernetes/minikube/releases)

2. Launch minikube with CNI:

```bash
$ minikube start \
  --vm-driver kvm2 \
  --network-plugin cni
```

3. Install `kubectl` via a package manager or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it
