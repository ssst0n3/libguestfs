IMAGE ?= libguestfs:local
PLATFORM ?= linux/amd64

.PHONY: help build size test check ci

help:
	@printf '%s\n' 'Available targets:'
	@printf '%s\n' '  make build     Build image ($(IMAGE)) for $(PLATFORM)'
	@printf '%s\n' '  make size      Print image size (bytes + human-readable)'
	@printf '%s\n' '  make test      Smoke tests: help + minimal qcow2 sparsify'
	@printf '%s\n' '  make check     Run build + size + test'
	@printf '%s\n' '  make ci        Run check, then buildx push with TAGS/LABELS env'

build:
	docker build --platform $(PLATFORM) -t $(IMAGE) -f Dockerfile .

size: build
	docker image inspect $(IMAGE) --format '{{.Size}}'
	docker images $(IMAGE)

test: build
	docker run --rm $(IMAGE) virt-sparsify --help
	docker run --rm -w /tmp $(IMAGE) bash -c 'set -eu; workdir=$$(mktemp -d); trap "rm -rf $$workdir" EXIT; cd "$$workdir"; qemu-img create -f qcow2 vm.qcow2 64M >/dev/null; virt-sparsify --compress vm.qcow2 shrunk.qcow2 >/dev/null'

check: build size test

ci: check
	@set -eu; \
	set --; \
	for tag in $$TAGS; do \
		set -- "$$@" -t "$$tag"; \
	done; \
	for label in $$LABELS; do \
		set -- "$$@" --label "$$label"; \
	done; \
	docker buildx build --platform $(PLATFORM) --push "$$@" -f Dockerfile .
