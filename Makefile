# Use docker images with this tag
# Effectively pins the demo to a specific release
GIT_TAG=v0.0.1-alpha.1

# Disk image filename
IMAGE=kubevirt-demo.img

.PHONY: run

# build: Build a final image
# Append init0 - so we can boot the image to finalize the bootstrap, and then shut it down again
build: FIRSTBOOT_APPEND=init 0
build: $(IMAGE)

# $image: Build the image without finalization
$(IMAGE): bootstrap-kubevirt.sh Makefile
	virt-builder centos-7.3 \
		--smp 4 --memsize 2048 \
		--output $@ \
		--format qcow2 \
		--size 20G \
		--hostname kubevirt-demo \
		--upload bootstrap-kubevirt.sh:/ \
		--root-password password: \
		--firstboot-command "GIT_TAG=$(GIT_TAG) bash -x /bootstrap-kubevirt.sh ; $(FIRSTBOOT_APPEND)"
	$(MAKE) run

# run: Run the image - will finalize on first boot
run:
	qemu-system-x86_64 --machine q35 \
		--cpu host --enable-kvm \
		--nographic -m 2048 -smp 4 \
		-net nic \
		-net user,hostfwd=:127.0.0.1:9091-:9090,hostfwd=:127.0.0.1:16510-:16509 \
		$(QEMU_APPEND) $(IMAGE)

# run-snapshot: Run without touching the image
run-snapshot: QEMU_APPEND=-snapshot
run-snapshot: run

check: build
	expect -f test-integration

clean:
	rm -vf $(IMAGE)
