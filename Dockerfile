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
    dpkg -r --force-depends \
      guestfs-tools \
      libguestfs-perl \
      libintl-perl \
      libstring-shellquote-perl \
      libsys-virt-perl \
      libwin-hivex-perl \
      perl \
      perl-base \
      perl-modules-5.36 \
      libperl5.36 \
      netpbm \
      osinfo-db \
      iso-codes \
      || true; \
    rm -f /usr/bin/qemu-system-x86_64-microvm /usr/bin/qemu-pr-helper /usr/bin/qemu-storage-daemon; \
    rm -rf /usr/share/perl /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl /usr/lib/x86_64-linux-gnu/perl5; \
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
    rm -rf /opt/rootfs/usr/share/zoneinfo /opt/rootfs/usr/share/X11; \
    rm -rf /opt/rootfs/usr/share/grub /opt/rootfs/usr/share/libvirt /opt/rootfs/usr/share/qemu/keymaps; \
    rm -rf /opt/rootfs/usr/share/augeas/lenses/dist/tests; \
    rm -f /opt/rootfs/usr/bin/qemu-system-i386; \
    rm -f /opt/rootfs/usr/libexec/qemu-system-i386; \
    rm -rf /opt/rootfs/usr/lib/ipxe; \
    rm -f /opt/rootfs/usr/lib/qemu/qemu-bridge-helper /opt/rootfs/usr/lib/qemu/virtfs-proxy-helper /opt/rootfs/usr/lib/qemu/virtiofsd; \
    rm -f /opt/rootfs/usr/lib/x86_64-linux-gnu/libapt-pkg.so* /opt/rootfs/usr/lib/x86_64-linux-gnu/libapt-private.so*; \
    rm -f /opt/rootfs/usr/share/qemu/openbios-* /opt/rootfs/usr/share/qemu/opensbi-* /opt/rootfs/usr/share/qemu/skiboot.lid /opt/rootfs/usr/share/qemu/slof.bin /opt/rootfs/usr/share/qemu/hppa-firmware.img /opt/rootfs/usr/share/qemu/palcode-clipper /opt/rootfs/usr/share/qemu/s390-*.img /opt/rootfs/usr/share/qemu/bamboo.dtb /opt/rootfs/usr/share/qemu/canyonlands.dtb /opt/rootfs/usr/share/qemu/npcm7xx_bootrom.bin /opt/rootfs/usr/share/qemu/trace-events-all; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/arch/x86/kvm /opt/rootfs/usr/lib/modules/*/kernel/arch/x86/events; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/drivers/infiniband /opt/rootfs/usr/lib/modules/*/kernel/drivers/comedi; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/ethernet/mellanox; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/fs/nfs /opt/rootfs/usr/lib/modules/*/kernel/fs/nfsd /opt/rootfs/usr/lib/modules/*/kernel/fs/smb /opt/rootfs/usr/lib/modules/*/kernel/fs/ceph /opt/rootfs/usr/lib/modules/*/kernel/fs/orangefs; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/net/sunrpc /opt/rootfs/usr/lib/modules/*/kernel/net/ceph /opt/rootfs/usr/lib/modules/*/kernel/net/sctp /opt/rootfs/usr/lib/modules/*/kernel/net/tipc /opt/rootfs/usr/lib/modules/*/kernel/net/openvswitch /opt/rootfs/usr/lib/modules/*/kernel/net/rds /opt/rootfs/usr/lib/modules/*/kernel/net/smc /opt/rootfs/usr/lib/modules/*/kernel/net/dccp /opt/rootfs/usr/lib/modules/*/kernel/net/l2tp; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/net/netfilter /opt/rootfs/usr/lib/modules/*/kernel/net/sched; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/bonding /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/wwan /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/wireguard /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/vxlan /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/team /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/hyperv /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/vmxnet3 /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/xen-netback; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/ethernet/amazon /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/ethernet/microsoft /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/ethernet/google /opt/rootfs/usr/lib/modules/*/kernel/drivers/net/ethernet/intel; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/drivers/hv /opt/rootfs/usr/lib/modules/*/kernel/drivers/xen; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/fs/btrfs /opt/rootfs/usr/lib/modules/*/kernel/fs/cachefiles /opt/rootfs/usr/lib/modules/*/kernel/fs/fscache /opt/rootfs/usr/lib/modules/*/kernel/fs/netfs /opt/rootfs/usr/lib/modules/*/kernel/fs/lockd /opt/rootfs/usr/lib/modules/*/kernel/fs/nfs_common; \
    rm -f /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/raid0.ko /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/raid1.ko /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/raid10.ko /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/raid456.ko /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/md-mod.ko /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/faulty.ko /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/multipath.ko; \
    rm -rf /opt/rootfs/usr/lib/modules/*/kernel/drivers/md/bcache; \
    rm -rf /opt/rootfs/usr/include /opt/rootfs/usr/src; \
    rm -f /opt/rootfs/boot/System.map-* /opt/rootfs/boot/config-* /opt/rootfs/boot/initrd.img-*; \
    rm -rf /opt/rootfs/usr/lib/apt; \
    rm -f /opt/rootfs/usr/bin/apt /opt/rootfs/usr/bin/apt-*; \
    rm -rf /opt/rootfs/etc/apt

FROM scratch

COPY --from=builder /opt/rootfs /

ENV LIBGUESTFS_BACKEND=direct \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["virt-sparsify", "--help"]
