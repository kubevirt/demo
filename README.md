# KubeVirt Demo

This demo will build a VM image, containing stock [Kubernetes](https://kubernetes.io)
and will deploy [KubeVirt](https://www.kubevirt.io) ontop of it.

You can use it to start playing with KubeVirt.

**Note:** It is not intended to be a development environment. You want
to use Vagrant (part of the KubeVirt repository) in that case.


## Requirements

You need to install the follwing tools:

- `make`
- `qemu-kvm`
- `virt-builder`
- `expect` (for `make check`)

On Fedora these are provided by the following packages:

```
$ dnf install -y make qemu-system-x86 libguestfs-tools-c expect
```


## Build

First you need to build the image:

```bash
$ git clone https://github.com/kubevirt/demo.git
$ cd demo
$ make build
```

This can take a while, as a base image and several containers are getting
downloaded an deployed inside the image.


## Check (optional)

If you want, then you can use `make check` to run a minimal integration test.
This will create a VM and check if it's really getting created in libvirtd.


## Use

**Note:** Use `root` to login without a password.

Now that the image is completed, you can use it:

```bash
$ make run
```

This will boot you into a virtual serial console of the VM.
First you need to login, once you are done, you can shut it down.


### `kubectl`

After the deployment you can use `kubectl` to create VMs:

```bash
$ kubectl create -f /vm.json
```

To view created VMs use the following command:

```bash
$ kubectl get vms
```


### `virsh`

You can also use `virsh` inside the VM to look at what is
happening in libvirt directly:

```bash
$ virsh list --all
```


### Cockpit

You can also view Cockpit rnuning inside the VM to look at the
Kubernetes topology and the involved KubeVirt components.

Just point yur browser to <https://127.0.0.1:9191/kubernetes>.
