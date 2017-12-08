# KubeVirt Demo

This demo will deploy [KubeVirt](https://www.kubevirt.io) on an existing
[minikube](https://github.com/kubernetes/minikube/).

This has been tested on the following distributions:

- Fedora 26 (minikube [kvm
  driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver))


## Quickstart

### Deploy KubeVirt

This demo assumes that [minikube](https://github.com/kubernetes/minikube/) is up and running and `kubectl` available on your system. If not, then please take a look at the guide [below](#deploying-minikube)

With minikube running, you can easily deploy KubeVirt:

```bash
$ export VERSION=v0.1.0
$ git clone https://github.com/kubevirt/demo.git
$ cd demo
$ kubectl create \
    -f https://github.com/kubevirt/kubevirt/releases/download/$VERSION/kubevirt.yaml \
    -f manifests/demo-pv.yaml
```

> **Note:** The initial deployment to a new minikube instance can take
> a long time, because a number of containers have to be pulled from the
> internet. Use `watch kubectl get --all-namespaces pods` to monitor the progress.

### Deploy a VirtualMachine

Once this is done you are ready to go:

```bash
# Creating a virtual machine
$ kubectl create -f manifests/vm.yaml

# After deployment you can manage VMs using the usual verbs:
$ kubectl get vms
$ kubectl get vms -o yaml testvm

# To delete: kubectl delete vms testvm
# To create your own: kubectl create -f $YOUR_VM_SPEC
```

### Accessing VMs (serial console & spice)

A separate binary is provided to get quick access to the serial and graphical
ports of a VM. The tool is called `virtctl` and can be retrieved from the
release page of KubeVirt:

```bash
# Get virtctl

$ curl -L -o virtctl \
    https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-linux-amd64
$ chmod a+x virtctl
```

Once the tool is available you still need to expose the KubeVirt API service, in
order to allow inbound access to the cluster:

```
# Expose access to the consoles via a service
$ kubectl expose service --namespace kube-system virt-api --type=NodePort --name kubevirt-api
```

Now you are ready to connect to the VMs:

```
# Connect to the serial console
$ ./virtctl console -s $(minikube service --url -n kube-system kubevirt-api) testvm

# Connect to the graphical display
$ ./virtctl spice -s $(minikube service --url -n kube-system kubevirt-api) testvm
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

### Deploying minikube

1. If not installed, install minikube as described [here](https://github.com/kubernetes/minikube/)

   1. Install the [driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md)
   2. Download the [`minikube` binary](https://github.com/kubernetes/minikube/releases)

2. Launch minikube with CNI:

```bash
$ minikube start \
  --vm-driver kvm \
  --network-plugin cni
```

3. Install `kubectl` via a package manager or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it
