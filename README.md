[![Build Status](https://travis-ci.org/kubevirt/demo.svg?branch=master)](https://travis-ci.org/kubevirt/demo)

# KubeVirt Demo

This demo will deploy [KubeVirt](https://www.kubevirt.io) on an existing
[minikube](https://github.com/kubernetes/minikube/) with Kubernetes 1.9 or
later.

> **Note:** Follow [this guide](README_minishift.md) in order to deploy the KubeVirt demo in minishift (running OpenShift).

## Quickstart

### Deploy KubeVirt

This demo assumes that [minikube](https://github.com/kubernetes/minikube/) is up and running and `kubectl` available on your system. If not, then please take a look at the guide [below](#appendix-deploying-minikube)

With minikube *RUNNING*, you can easily deploy KubeVirt:

```bash
$ export VERSION=v0.7.0-alpha.0
$ kubectl apply \
    -f https://github.com/kubevirt/kubevirt/releases/download/$VERSION/kubevirt.yaml
```

> **Note:** The initial deployment to a new minikube instance can take
> a long time, because a number of containers have to be pulled from the
> internet. Use `watch kubectl get --all-namespaces pods` to monitor the progress.

### Install virtctl

> **Note:** This requires `kubectl` from Kubernetes 1.9 or later on the client

An additional binary is provided to get quick access to the serial and graphical ports of a VM, and handle start/stop operations.
The tool is called `virtctl` and can be retrieved from the release page of KubeVirt:

```bash
$ curl -L -o virtctl \
    https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-linux-amd64
$ chmod +x virtctl
```

### Deploy a VirtualMachine

Once you deployed KubeVirt you are ready to launch a VM:

```bash
# Creating a virtual machine
$ kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml

# After deployment you can manage VMs using the usual verbs:
$ kubectl get vms
$ kubectl get vms -o yaml testvm

# To start a VM you can use
$ ./virtctl start testvm

# Afterwards you can inspect the instances
$ kubectl get vmis
$ kubectl get vmis -o yaml testvm

# To shut it down again
$ ./virtctl stop testvm

# To delete
$ kubectl delete vms testvm
# To create your own
$ kubectl apply -f $YOUR_VM_SPEC
```

### Accessing VMs (serial console & vnc)

```
# Connect to the serial console
$ ./virtctl console testvm

# Connect to the graphical display
# Note: Requires `remote-viewer` from the `virt-viewer` package.
$ ./virtctl vnc testvm
```

## Next steps

### User Guide

Now that KubeVirt is up an running, you can take a look at the [user guide](http://docs.kubevirt.io/) to understand how you can create and manage your own virtual machines.

## Appendix: Deploying minikube

1. If not installed, install minikube as described [here](https://github.com/kubernetes/minikube/):

   1. Install the [kvm2 driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver)
   2. Download the [`minikube` binary](https://github.com/kubernetes/minikube/releases)

2. Verify nested virtualization is enabled on the machine minikube is being installed on:

```bash
$ cat /sys/module/kvm_intel/parameters/nested
Y
```

3. Launch minikube with CNI:

```bash
$ minikube start \
  --vm-driver kvm2 \
  --network-plugin cni
```

4. Install `kubectl` via a [package manager](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-native-package-management) or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it
