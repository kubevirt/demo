#!/bin/bash

set -e

oc version
oc cluster up --skip-registry-check --enable=-router
oc cluster down
sed -i "/kind/ a\kubeletArguments:\n  feature-gates:\n  - DevicePlugins=true" $PWD/openshift.local.clusterup/node/node-config.yaml
oc cluster up --skip-registry-check

oc login -u system:admin
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-privileged
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-controller
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-apiserver

# Workaround for https://github.com/openshift/origin/pull/20351
KUBELET_ROOTFS=$(sudo docker inspect $(sudo docker ps | grep kubelet | cut -d" " -f1) | jq -r ".[0].GraphDriver.Data.MergedDir" -)
sudo mkdir -p /var/lib/kubelet/device-plugins $KUBELET_ROOTFS/var/lib/kubelet/device-plugins
sudo mount -o bind $KUBELET_ROOTFS/var/lib/kubelet/device-plugins /var/lib/kubelet/device-plugins
sudo ls /var/lib/kubelet/device-plugins
#sudo mount --make-rshared $KUBELET_ROOTFS/var/lib/kubelet/device-plugins

