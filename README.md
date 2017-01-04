# KubeVirt Demo

This demo will build a VM image, containing stock Kubernetes and
will deploy KubeVirt ontop of it.

You can use it to start playing with KubeVirt.

**Note:** It is not intended to be a development environment. You want
to use Vagrant in that case.

## Requirements

You need to install

- `qemu-kvm`
- `virt-builder`

## Build & Deploy

First you need to build the image:

```bash
$ make build
```

Afterwards you can run the image:

```bash
$ make run
```

The deployment of Kubernetes and KubeVirt is taking place during
the first boot. You can use the following command to follow the
deployment process:

**Note:** Use `root` to login without a password.

```bash
$ journalctl -f -u guestfs-firstboot
```

## Use

**Note:** Use `root` to login without a password.

There are now a few things you can do _inside the VM_:

### `kubectl`

After the deployment you can use `kubectl` to create VMs.

> FIXME TBD

### Cockpit

You can also view Cockpit rnuning inside the VM to look at the
Kubernetes topology and the involved KubeVirt components.

Just point yur browser to <https://127.0.0.1:9191/kubernetes>.


### `virsh`

You can also use `virsh` inside the VM to look at what is
happening in libvirt directly:

```bash
$ yum install -y libvirt-client
$ virsh -c qemu+tcp://127.0.0.1/system
```

> FIXME Sort out authentication
