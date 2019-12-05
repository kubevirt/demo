[![Build Status](https://travis-ci.org/kubevirt/demo.svg?branch=master)](https://travis-ci.org/kubevirt/demo)

# KubeVirt Demo

This demo will guide you through setting up [KubeVirt](https://www.kubevirt.io) on

- [minikube](#setting-up-minikube) 1.2+
- [kind](#setting-up-kind) 0.4+
- [minishift](#running-on-okd-or-minishift) with OKD 3.12+

## Quickstart

### Deploy KubeVirt

This demo assumes that `minikube` or `minishift` is [configured and running as described
below](#setting-up-minikube) and that `kubectl` available on your system. If not, then
please take a look at the guide [below](#setting-up-minikube).

The first step is to start `minikube`:

```bash
$ minikube config set vm-driver kvm2
$ minikube start --memory 4096
😄  minikube v1.0.1 on linux (amd64)
💿  Downloading Minikube ISO ...
 142.88 MB / 142.88 MB [============================================] 100.00% 0s
🤹  Downloading Kubernetes v1.14.1 images in the background ...
🔥  Creating kvm2 VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
📶  "minikube" IP address is 192.168.39.47
🐳  Configuring Docker as the container runtime ...
🐳  Version of container runtime is 18.06.3-ce
⌛  Waiting for image downloads to complete ...
✨  Preparing Kubernetes environment ...
💾  Downloading kubelet v1.14.1
💾  Downloading kubeadm v1.14.1
🚜  Pulling images required by Kubernetes v1.14.1 ...
🚀  Launching Kubernetes v1.14.1 using kubeadm ...
⌛  Waiting for pods: apiserver proxy etcd scheduler controller dns
🔑  Configuring cluster permissions ...
🤔  Verifying component health .....
💗  kubectl is now configured to use "minikube"
🏄  Done! Thank you for using minikube!
```

Before we can deploy KubeVirt we create a small config, to adjust KubeVirt to your
environment. Specifically enabling software emulation for your VMs in case that no
hardware virtualization support is present.

```bash
$ kubectl create namespace kubevirt

# Either nesting as described [below](#setting-up-minikube) will be used, or we configure emulation if
# no nesting is available:
$ minikube ssh -- test -e /dev/kvm \
  || kubectl create configmap -n kubevirt kubevirt-config --from-literal debug.useEmulation=true
```

Now you are finally ready to deploy KubeVirt using our operator (comparable to an installer):

```bash
$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v0.23.0/kubevirt-operator.yaml
…
deployment.apps/virt-operator created

$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v0.23.0/kubevirt-cr.yaml
kubevirt.kubevirt.io/kubevirt created
```

The initial deployment can take a long time, because a number of pods have to be pulled from the internet.
We'll watch the operator status to determine when the deployment is completed:

```bash
$ kubectl wait --timeout=180s --for=condition=Available -n kubevirt kv/kubevirt
kubevirt.kubevirt.io/kubevirt condition met
```

Congratulations, KubeVirt was successfully deployed.

### Install virtctl

An additional binary is provided to get quick access to the serial and graphical ports of a VM, and handle start/stop operations.
The tool is called `virtctl` and can be retrieved from the release page of KubeVirt:

```bash
$ curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/v0.23.0/virtctl-v0.23.0-linux-amd64
$ chmod +x virtctl
```

#### Installing with krew

If you installed [krew](https://krew.dev), you can install virtctl as a kubectl plugin:

```bash
$ kubectl krew install virt
```

### Starting and stopping a VirtualMachine

Once you deployed KubeVirt you are ready to launch a VM:

*if `virtctl` is installed via krew, please use `kubectl virt ...` instead of `./virtctl ...`*

```bash
# Creating a virtual machine
$ kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml

# After deployment you can manage VMs using the usual verbs:
$ kubectl describe vm testvm

# To start a VM you can use, this will create a VM instance (VMI)
$ ./virtctl start testvm

# The interested reader can now optionally inspect the instance
$ kubectl describe vmi testvm

# To shut the VM down again:
$ ./virtctl stop testvm

# To delete
$ kubectl delete vm testvm
# To create your own
$ kubectl apply -f $YOUR_VM_SPEC
```

### Accessing VMs (serial console & VNC)

*if `virtctl` is installed via krew, please use `kubectl virt ...` instead of `./virtctl ...`*

```bash
# Connect to the serial console
$ ./virtctl console testvm

# Connect to the graphical display
# This requires remote-viewer from the virt-viewer package and a graphical desktop from where oyu run virtctl
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
$ minikube start --vm-driver kvm2 --memory 4096
```

3. Install `kubectl` via a [package manager](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-native-package-management) or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it

### Setting up `kind`

1. If not installed, install kind as described [here](https://github.com/kubernetes-sigs/kind)

2. Launch kind

```bash
$ tee cluster.yaml <<EOC
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
- role: worker
- role: worker
EOC

$ kind create cluster --config cluster.yaml
```


### Running on _OKD_ or `minishift`

OKD is just another Kubernetes distribution, and you can also use `kubectl` to interact with such a cluster.
However, the `oc` tool is part of OKD and provides additional commands for managing your cluster.

1. Get the `oc` tool

  1. Download the _openshift-client-tools_ tarball from [here](https://github.com/openshift/origin/releases):
  2. Extract the `oc` tool from the API tool `tar xf openshift-origin-client-tools*.tar.gz`

2. Launch `oc cluster`:

```bash
oc cluster up --skip-registry-check --enable=router,sample-templates
```
