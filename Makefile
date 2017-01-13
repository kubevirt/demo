# Use docker images with this tag
# Effectively pins the demo to a specific release
GIT_TAG=v0.0.1-alpha.2

# Disk image filename
IMAGE=kubevirt-demo.img

build: data/bootstrap-kubevirt.sh Makefile
	virt-builder centos-7.3 \
		--smp 4 --memsize 2048 \
		--output $(IMAGE) \
		--format qcow2 \
		--size 20G \
		--hostname kubevirt-demo \
		--upload data/bootstrap-kubevirt.sh:/ \
		--root-password password: \
		--firstboot-command "GIT_TAG=$(GIT_TAG) bash -x /bootstrap-kubevirt.sh ; init 0 ;"
	@echo "Deploying KubeVirt - This can take a while (progress: tail -f build.log)"
	@./run-demo.sh $(IMAGE) 2>&1 > build.log
	@echo "KubeVirt got deployed successful."

install:
	@virsh domstate kubevirt-demo 2>/dev/null && echo "ERR: There is already a kubevirt-demo domain" || :
	virt-install \
		--name kubevirt-demo \
		--memory 2048 \
		--vcpus 4 \
		--cpu host \
		--import \
		--disk $(IMAGE),format=qcow2 \
		--network user \
		--graphics none \
		--noautoconsole \
		--noreboot
	virsh start kubevirt-demo

uninstall:
	virsh destroy kubevirt-demo || :
	virsh undefine kubevirt-demo
		

check: $(IMAGE) data/test-integration
	QEMU_APPEND=-snapshot expect -f data/test-integration

clean:
	rm -vf $(IMAGE) build.log
