FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    LIBGUESTFS_BACKEND=direct

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      guestfs-tools \
      linux-image-cloud-amd64; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /opt/rootfs; \
    cp -a /bin /boot /etc /lib /lib64 /sbin /usr /var /opt/rootfs/; \
    mkdir -p /opt/rootfs/tmp; \
    rm -rf /opt/rootfs/var/cache/apt /opt/rootfs/var/lib/apt/lists /opt/rootfs/var/log/*; \
    rm -f /opt/rootfs/boot/System.map-* /opt/rootfs/boot/config-* /opt/rootfs/boot/initrd.img-*

FROM scratch

COPY --from=builder /opt/rootfs /

ENV LIBGUESTFS_BACKEND=direct \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["virt-sparsify", "--help"]
