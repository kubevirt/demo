# Use docker images with this tag
# Effectively pins the demo to a specific release
DOCKER_TAG=v0.0.1-alpha.1

# Disk image filename
IMAGE=kubevirt-demo.img

# build: Build a final image
# Append init0 - so we can boot the image to finalize the bootstrap, and then shut it down again
build: FIRSTBOOT_APPEND=init 0
build: $(IMAGE) run

# $image: Build the image without finalization
$(IMAGE):
	virt-builder centos-7.3 \
		--smp 4 --memsize 2048 \
		--output $@ \
		--format qcow2 \
		--size 20G \
		--hostname kubevirt-demo \
		--upload bootstrap-kubevirt.sh:/ \
		--root-password password: \
		--firstboot-command "DOCKER_TAG=$(DOCKER_TAG) bash -x /bootstrap-kubevirt.sh ; $(FIRSTBOOT_APPEND)"

# run: Run the image - will finalize on first boot
run: $(IMAGE)
	qemu-kvm --machine q35 --cpu host \
		--nographic -m 2048 -smp 4 \
		-net nic \
		-net user,hostfwd=:127.0.0.1:9091-:9090,hostfwd=:127.0.0.1:16510-:16509 \
		$(QEMU_APPEND) $(IMAGE)

# run-snapshot: Run without touching the image
run-snapshot: QEMU_APPEND=-snapshot
run-snapshot: run

clean:
	rm -vf $(IMAGE)
