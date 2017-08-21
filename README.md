# KubeVirt Demo

This demo can be used to deploy [KubeVirt](https://www.kubevirt.io) on
[minikube](https://github.com/kubernetes/minikube/).

You can use it to start playing with KubeVirt.

This has been tested on the following distributions:

- Fedora 25 (minikube kvm driver)
- Ubuntu 16.04.1 LTS (Xenial Xerus)


## Quickstart

> Please be aware: The initial deployment to a new minikube instance can take
> a logn time, because a number of containers has to be pulled from the
> internet.

1. Install minikube as described here: https://github.com/kubernetes/minikube/

2. Deploy KubeVirt on it

```bash
git clone https://github.com/kubevirt/demo.git
cd demo
./run-demo.sh
```

Congratulations, KubeVirt should be working now. You can now start to manage
VMs:

```bash
# After deployment you can manage VMs using the usual verbs:
kubectl get vms
kubectl delete vms testvm
kubectl create -f $YOUR_VM_SPEC
```

### Accessing VMs

Currently you need a separate tool to access the graphical display or serial
console of a VM, you can retrieve it using:

```bash
curl -LO https://github.com/kubevirt/kubevirt/releases/download/v0.0.1-alpha.6/virtctl
chmod a+x virtctl
```

Now you can connect to a serial or SPICE console:

```bash
# For a serial console (if present in VM)
./virtctl console testvm

# For a SPICE connectionwith remote-viewer (if SPICE is configured for VM)
./virtctl spice testvm

# ... or for just the connection details
./virtctl spice --details testvm
```

### Removal

To remove all traces of Kubevirt, you can undeploy it using:

```bash
./run-demo.sh undeploy
```

## Kubernetes Dashboard

The dashboard is provided as a minikube add-on. To enable it run:

```bash
minikube addon enable dashboard
```

