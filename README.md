[![Build Status](https://travis-ci.org/kubevirt/demo.svg?branch=master)](https://travis-ci.org/kubevirt/demo)

# KubeVirt Demo

This demo will guide you through setting up [KubeVirt](https://www.kubevirt.io) on

- [minikube](#setting-up-minikube) with Kubernetes 1.10+
- [minishift](#running-on-okd-or-minishift) with OKD 3.11+

## Quickstart

### Deploy KubeVirt

This demo assumes that `minikube` (0.28+) (or `minishift`) is [configured and
running as described below](#setting-up-minikube) and that `kubectl` available on
your system. If not, then please take a look at the guide [below](#setting-up-minikube).

The first step is to start `minikube`:

```bash
$ minikube start --vm-driver kvm2 --feature-gates=DevicePlugins=true --memory 4096
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.

# Enable nesting as described [below](#setting-up-minikube)
# OR Enable emulation mode when nested virtualization is not available or you don't want to use it
$ kubectl create namespace kubevirt
$ kubectl create configmap -n kubevirt kubevirt-config --from-literal debug.useEmulation=true
```

> **Note:** When deploying KubeVirt on `minishift`, you will need [to install openshift-client-tools and add the following SCCs](#running-on-okd-or-minishift) prior kubevirt.yaml deployment.

Once it is runing KubeVirt can be deployed:

```bash
$ export VERSION=v0.13.1
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

### Setting up `Minikube`

1. (Optional) Minikube has support for nested virtualization, it can be enabled as described [here](https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/).

2. If not installed, install minikube as described [here](https://github.com/kubernetes/minikube/):

   1. Install the [kvm2 driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver)
   2. Download the [`minikube` binary](https://github.com/kubernetes/minikube/releases)

3. Launch minikube with the desired memory

```bash
$ minikube start --vm-driver kvm2 --feature-gates=DevicePlugins=true --memory 4096
```

3. Install `kubectl` via a [package manager](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-native-package-management) or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it

### Running on _OKD_ or `minishift`

1. Get the `oc` tool

  1. Download the _openshift-client-tools_ tarball from [here](https://github.com/openshift/origin/releases):
  2. Extract the `oc` tool from the API tool `tar xf openshift-origin-client-tools*.tar.gz`

2. Launch `oc cluster`:

```bash
oc cluster up --skip-registry-check --enable=router,sample-templates
```

In addition to the deployment, grant the KubeVirt components some additional roles:

```bash
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-privileged
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-controller
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-apiserver
```
