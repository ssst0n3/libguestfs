FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    LIBGUESTFS_BACKEND=direct

RUN set -eux; \
    mkdir -p /etc/dpkg/dpkg.cfg.d; \
    printf '%s\n' \
      'path-exclude=/usr/share/doc/*' \
      'path-exclude=/usr/share/man/*' \
      'path-exclude=/usr/share/locale/*' \
      'path-exclude=/usr/share/bash-completion/*' \
      'path-exclude=/usr/share/info/*' \
      'path-include=/usr/share/locale/locale.alias' \
      > /etc/dpkg/dpkg.cfg.d/01_nodoc; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      guestfs-tools \
      linux-image-cloud-amd64; \
    mv /usr/bin/virt-sparsify /tmp/virt-sparsify; \
    rm -f /usr/bin/virt-* /usr/sbin/virt-*; \
    mv /tmp/virt-sparsify /usr/local/bin/virt-sparsify; \
    rm -f /usr/bin/qemu-system-x86_64-microvm /usr/bin/qemu-pr-helper /usr/bin/qemu-storage-daemon; \
    rm -rf /etc/virt-builder; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /opt/rootfs; \
    cp -a /bin /boot /etc /lib /lib64 /sbin /usr /opt/rootfs/; \
    mkdir -p /opt/rootfs/var/lib; \
    cp -a /var/lib/dpkg /opt/rootfs/var/lib/; \
    mkdir -p /opt/rootfs/tmp /opt/rootfs/var/tmp; \
    rm -rf /opt/rootfs/var/cache/apt /opt/rootfs/var/lib/apt /opt/rootfs/var/log/*; \
    rm -rf /opt/rootfs/usr/share/doc /opt/rootfs/usr/share/man /opt/rootfs/usr/share/info /opt/rootfs/usr/share/bash-completion; \
    rm -rf /opt/rootfs/usr/include /opt/rootfs/usr/src; \
    rm -f /opt/rootfs/boot/System.map-* /opt/rootfs/boot/config-*; \
    rm -rf /opt/rootfs/usr/lib/apt; \
    rm -f /opt/rootfs/usr/bin/apt /opt/rootfs/usr/bin/apt-*; \
    rm -rf /opt/rootfs/etc/apt

FROM scratch

COPY --from=builder /opt/rootfs /

ENV LIBGUESTFS_BACKEND=direct \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["virt-sparsify", "--help"]
