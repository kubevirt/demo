# KubeVirt Demo

This demo will deploy [KubeVirt](https://www.kubevirt.io) on an existing
[minikube](https://github.com/kubernetes/minikube/).

[![asciicast](https://asciinema.org/a/134953.png)](https://asciinema.org/a/134953)

This has been tested on the following distributions:

- Fedora 25 (minikube [kvm
  driver](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver))


## Quickstart

> **Note:** The initial deployment to a new minikube instance can take
> a long time, because a number of containers have to be pulled from the
> internet.

> **Note:** Due to [this
> issue](https://github.com/kubernetes/minikube/issues/1845), currently a
> pre-release minikube iso is required. Use the following snippet to launch
> minikube using the custom iso:
> ```bash
> $ minikube start --vm-driver kvm --network-plugin cni \
>   --iso-url https://storage.googleapis.com/minikube-builds/1846/minikube-testing.iso
> ```


1. If not installed, install minikube as described here:
   https://github.com/kubernetes/minikube/

2. Launch minikube with CNI:


```bash
$ minikube start --vm-driver kvm --network-plugin cni
```

3. Deploy KubeVirt on it

```bash
$ git clone https://github.com/kubevirt/demo.git
$ cd demo
$ ./run-demo.sh
$ ./run-demo.sh 
KubeVirt (v0.0.1-alpha.6) demo on minikube
- Checking kubectl version ... OK
- Checking for minikube ... OK
- Checking out KubeVirt ... OK
- Deploying manifests - this can take several minutes!
vm "testvm" created
- Waiting for the cluster to be ready ...
  Cluster changed, checking if KubeVirt is ready ... Not yet.
...
  Cluster changed, checking if KubeVirt is ready ... Yes!
KubeVirt is now ready.
Optional, register the virt plugin for VM access:
  ./run-demo.sh plug
Try: $ kubectl get vms

# Run a script to verify that it operates correctly
$ ./test.sh
$ ./test.sh 
README contains correct version ... OK
VM is running ... OK
VM serial console works ... OK
PASS
```

4. Start managing VMs

```bash
# After deployment you can manage VMs using the usual verbs:
$ kubectl get vms
$ kubectl get vms -o json

# To delete: kubectl delete vms testvm
# To create your own: kubectl create -f $YOUR_VM_SPEC
```

### Accessing VMs (serial console & spice)

Currently you need a separate tool to access the graphical display or serial
console of a VM, you can install it as a `kubelet` plugin using:

```bash
$ ./run-demo.sh plug
KubeVirt (v0.0.1-alpha.6) demo on minikube
- Checking kubectl version ... OK
- Fetching and registering virtctl ... OK

# Now the plugin is ready to use

# Connect to the serial console
$ kubectl plugin virt -- console -s http://$(minikube ip):8184 testvm

# Connect to the graphical display
$ kubectl plugin virt -- spice -s http://$(minikube ip):8184 testvm
```

### Removal

To remove all traces of Kubevirt, you can undeploy it using:

```bash
$ ./run-demo.sh undeploy
$ ./run-demo.sh unplug
```
```
