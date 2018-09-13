[![Build Status](https://travis-ci.org/kubevirt/demo.svg?branch=master)](https://travis-ci.org/kubevirt/demo)

# KubeVirt Demo

This demo will deploy [KubeVirt](https://www.kubevirt.io) on an existing
[minikube](https://github.com/kubernetes/minikube/) with Kubernetes 1.10 or
later.

Instructions for [openshift origin](#running-on-openshift-origin) are also provided

## Quickstart

### Deploy KubeVirt

This demo assumes that `minikube` is [configured and running as described below](#setting-up-minikube) and that `kubectl` is available on your system.

With minikube *RUNNING*, you can easily deploy KubeVirt:

> If your host does not support hardware virtualization, then you will
> need to enable software emulation using:
> `kubectl create configmap -n kube-system kubevirt-config --from-literal
> debug.allowEmulation=true`

```bash
$ export VERSION=v0.8.0
$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/$VERSION/kubevirt.yaml
```

> The initial deployment can take a long time, because a number of
> containers have to be pulled from the internet. Use
> `watch kubectl get --all-namespaces pods` to monitor the progress.


### Install virtctl

An additional binary is provided to get quick access to the serial and graphical ports of a VM, and handle start/stop operations.
The tool is called `virtctl` and can be retrieved from the release page of KubeVirt:

```bash
$ curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-linux-amd64
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
# It Requires remote-viewer from the virt-viewer package.
$ ./virtctl vnc testvm
```

## Next steps

### User Guide

Now that KubeVirt is up an running, you can take a look at the [user guide](http://docs.kubevirt.io/) to understand how you can create and manage your own virtual machines.

## Appendix

### Setting up `nested virtualization`

1. Enable it:

```bash
$ sudo sh -c "echo options kvm-intel nested=1 >> /etc/modprobe.d/kvm-intel.conf"
$ sudo modprobe -r kvm_intel
$ sudo modprobe kvm_intel
```

2. Verify that nested virtualization is enabled:

```bash
$ cat /sys/module/kvm_intel/parameters/nested
Y
```

### Setting up `Minikube`

1. If not installed, install minikube as described [here](https://github.com/kubernetes/minikube/):

   1. Install the [kvm2 driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver)
   2. Download the [`minikube` binary](https://github.com/kubernetes/minikube/releases)

2. Launch minikube with the desired memory

```bash
$ minikube start --vm-driver kvm2 --feature-gates=DevicePlugins=true --memory 4096
```

3. Install `kubectl` via a [package manager](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-native-package-management) or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it

### Running on `Origin`

> `oc cluster` currently (v3.10) has a bug which requires and additional step.

1. Get the `oc` tool

  1. Download the _openshift-client-tools_ tarball from [here](https://github.com/openshift/origin/releases):
  2. Extract the `oc` tool from the API tool `tar xf openshift-origin-client-tools*.tar.gz`

2. Launch `oc cluster`:

```bash
oc cluster up --skip-registry-check --enable=router,sample-templates
```

Apply the following workaround:

```bash
# Fix device plugins
# Workaround for https://github.com/openshift/origin/pull/20351
KUBELET_ROOTFS=$(sudo docker inspect $(sudo docker ps | grep kubelet | cut -d" " -f1) | jq -r ".[0].GraphDriver.Data.MergedDir" -)
sudo mkdir -p /var/lib/kubelet/device-plugins $KUBELET_ROOTFS/var/lib/kubelet/device-plugins
sudo mount -o bind $KUBELET_ROOTFS/var/lib/kubelet/device-plugins /var/lib/kubelet/device-plugins
sudo ls /var/lib/kubelet/device-plugins
```

In addition to the deployment, grant the KubeVirt components some additional roles:

```bash
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-privileged
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-controller
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-apiserver
```
