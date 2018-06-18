[![Build Status](https://travis-ci.org/kubevirt/demo.svg?branch=master)](https://travis-ci.org/kubevirt/demo)

# KubeVirt on top of minishift Demo

This demo will deploy [KubeVirt](https://www.kubevirt.io) on top of [Minishift v1.17.0](https://www.openshift.org/minishift/).

#### Install Minishift

Download the archive for your operating system from the Minishift Releases page (https://github.com/minishift/minishift/releases) and extract its contents.

Copy the contents of the directory to your preferred location and add the minishift binary to your PATH environment variable.


#### Start Minishift
```
$ minishift start
```

You should expect to see the following:

```
-- Starting local OpenShift cluster using 'kvm' hypervisor...
...
   OpenShift server started.
   The server is accessible via web console at:
       https://192.168.99.128:8443

   You are logged in as:
       User:     developer
       Password: developer

   To login as administrator:
       oc login -u system:admin

Note: for further information please see https://docs.openshift.org/latest/minishift/getting-started/quickstart.html
```

Note: In case you get the following error: "...Hit github rate limit: GET https://api.github.com/repos/openshift/origin/releases: 403 API rate limit exceeded...", do the following:
1) goto your account setting in GitHub -> Developer settings -> Personal access tokens, and create a new token.
2) export this token: export MINISHIFT_GITHUB_API_TOKEN=<the token id you generated>

#### Install KubeVirt

```
$ oc login -u system:admin

$ export VERSION=v0.5.0
$ kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$VERSION/kubevirt.yaml
```

Define the following policies:

```
$ oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-privileged
$ oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-controller
$ oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-apiserver
$ oc adm policy add-scc-to-user hostmount-anyuid -z kubevirt-infra -n kube-system
```


#### Install virtctl
This tool provides quick access to the serial and graphical ports of a VM, and handle start/stop operations.

```
$ export VERSION=v0.5.0
$ curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/$VERSION/virtctl-$VERSION-linux-amd64
$ chmod +x virtctl
```


#### Create an Offline  VM
Note: Install `kubectl` via a [package manager](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-native-package-management) or [download](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl) it

```$ kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml```


#### Manage Virtual Machines (optional):

To get a list of existing offline Virtual Machines:
```
$ oc get ovms
$ oc get ovms -o yaml testvm
```

To start an offline VM you can use:
```
$ ./virtctl start testvm
```

To get a list of existing virtual machines:
```
$ oc get vms
$ oc get vms -o yaml testvm
```

To shut it down again:
```
$ ./virtctl stop testvm
```

To delete an offline Virtual Machine:
```
$ oc delete ovms testvm
```

#### Accessing VMs (serial console & spice)

Connect to the serial console

```
$ ./virtctl console testvm
```

Connect to the graphical display
Note: Requires `remote-viewer` from the `virt-viewer` package.
```
$ ./virtctl vnc testvm
```


#### Appendix:

Install kvm driver if not exists:
```$  yum install -y qemu-kvm```
 
