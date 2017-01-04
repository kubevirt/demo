IMAGE=demo.img

build: $(IMAGE)

$(IMAGE):
	virt-builder centos-7.3 \
		--smp 4 --memsize 2048 \
		--output $@ \
		--format qcow2 \
		--size 20G \
		--hostname demo.kubevirt.io \
		--upload setup-k8s.sh:/ \
		--root-password password: \
		--firstboot-command "bash -x /setup-k8s.sh"

run: $(IMAGE)
	qemu-kvm --machine q35 -snapshot $(IMAGE) -m 2048 -smp 4 -net nic -net user,hostfwd=:127.0.0.1:9191-:9090

clean:
	rm -vf $(IMAGE)
