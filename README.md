# KubeVirt Demo

This demo can be used to deploy [KubeVirt](https://www.kubevirt.io) on
[minikube](https://github.com/kubernetes/minikube/).

You can use it to start playing with KubeVirt.

This has been tested on the following distributions:

- Fedora 25 (minikube [kvm
  driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver))


## Quickstart

> **Note:** The initial deployment to a new minikube instance can take
> a long time, because a number of containers have to be pulled from the
> internet.

1. If not installed, install minikube as described here:
   https://github.com/kubernetes/minikube/

2. Launch minikube with CNI:

> **Note:** Due to [this
> issue](https://github.com/kubernetes/minikube/issues/1845), currently a
> pre-release minikube iso is required. Use the following snippet to launch
> minikube using the custom iso:
> ```bash
> $ minikube start --vm-driver kvm --network-plugin cni \
>   --iso-url https://storage.googleapis.com/minikube-builds/1846/minikube-testing.iso
> ```

```bash
$ minikube start --vm-driver kvm --network-plugin cni
```

3. Deploy KubeVirt on it

```bash
$ git clone https://github.com/kubevirt/demo.git
$ cd demo
$ ./run-demo.sh
```

Congratulations, KubeVirt should be working now. To verify it run:

```bash
./test.sh
VM is running ... OK
PASS
```

If it passes, then you can now start to manage VMs:

```bash
# After deployment you can manage VMs using the usual verbs:
$ kubectl get vms
$ kubectl get vms -o json

# To delete: kubectl delete vms testvm
# To create your own: kubectl create -f $YOUR_VM_SPEC
```

### Accessing VMs (serial console & spice)

Currently you need a separate tool to access the graphical display or serial
console of a VM, you can retrieve it using:

```bash
$ curl -LO https://github.com/kubevirt/kubevirt/releases/download/v0.0.1-alpha.6/virtctl
$ chmod a+x virtctl

# Connect to the serial console
$ ./virtctl console -s http://$(minikube ip):8184 testvm -d serial0

# Connect to the graphical display
$ ./virtctl spice -s http://$(minikube ip):8184 testvm
```

### Removal

To remove all traces of Kubevirt, you can undeploy it using:

```bash
$ ./run-demo.sh undeploy
```

## Kubernetes Dashboard

The dashboard is provided as a minikube add-on. To enable it run:

```bash
$ minikube addon enable dashboard
```
