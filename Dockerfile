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
    rm -f /opt/rootfs/var/lib/dpkg/info/*.md5sums /opt/rootfs/var/lib/dpkg/info/*.symbols /opt/rootfs/var/lib/dpkg/info/*.templates; \
    mkdir -p /opt/rootfs/tmp /opt/rootfs/var/tmp; \
    rm -rf /opt/rootfs/var/cache/apt /opt/rootfs/var/lib/apt /opt/rootfs/var/log/*; \
    find /opt/rootfs/usr/share -mindepth 1 -maxdepth 1 \
      ! -name qemu \
      ! -name seabios \
      ! -name misc \
      -exec rm -rf {} +; \
    find /opt/rootfs/usr/share/misc -mindepth 1 -maxdepth 1 \
      ! -name magic \
      ! -name magic.mgc \
      -exec rm -rf {} +; \
    rm -f /opt/rootfs/usr/bin/qemu-system-i386; \
    rm -f /opt/rootfs/usr/libexec/qemu-system-i386; \
    rm -rf /opt/rootfs/usr/lib/ipxe; \
    rm -f /opt/rootfs/usr/lib/qemu/qemu-bridge-helper /opt/rootfs/usr/lib/qemu/virtfs-proxy-helper /opt/rootfs/usr/lib/qemu/virtiofsd; \
    rm -f /opt/rootfs/usr/lib/x86_64-linux-gnu/libapt-pkg.so* /opt/rootfs/usr/lib/x86_64-linux-gnu/libapt-private.so*; \
    rm -f /opt/rootfs/usr/share/qemu/openbios-* /opt/rootfs/usr/share/qemu/opensbi-* /opt/rootfs/usr/share/qemu/skiboot.lid /opt/rootfs/usr/share/qemu/slof.bin /opt/rootfs/usr/share/qemu/hppa-firmware.img /opt/rootfs/usr/share/qemu/palcode-clipper /opt/rootfs/usr/share/qemu/s390-*.img /opt/rootfs/usr/share/qemu/bamboo.dtb /opt/rootfs/usr/share/qemu/canyonlands.dtb /opt/rootfs/usr/share/qemu/npcm7xx_bootrom.bin /opt/rootfs/usr/share/qemu/trace-events-all; \
    rm -f /opt/rootfs/usr/share/seabios/vgabios*; \
    for moddir in /opt/rootfs/usr/lib/modules/*/kernel; do \
      find "$moddir/drivers" -mindepth 1 -maxdepth 1 -type d \
        ! -name acpi \
        ! -name ata \
        ! -name block \
        ! -name cdrom \
        ! -name char \
        ! -name firmware \
        ! -name md \
        ! -name net \
        ! -name nvdimm \
        ! -name nvme \
        ! -name pci \
        ! -name scsi \
        ! -name uio \
        ! -name virtio \
        ! -name vhost \
        ! -name watchdog \
        -exec rm -rf {} +; \
      find "$moddir/fs" -mindepth 1 -maxdepth 1 \
        ! -name autofs \
        ! -name configfs \
        ! -name efivarfs \
        ! -name fat \
        ! -name fuse \
        ! -name isofs \
        ! -name nls \
        ! -name overlayfs \
        ! -name pstore \
        ! -name quota \
        ! -name xfs \
        -exec rm -rf {} +; \
      find "$moddir/net" -mindepth 1 -maxdepth 1 -type d \
        ! -name core \
        ! -name ipv4 \
        ! -name ipv6 \
        ! -name netlink \
        ! -name unix \
        -exec rm -rf {} +; \
      rm -rf "$moddir/arch/x86/kvm" "$moddir/arch/x86/events"; \
      rm -rf "$moddir/drivers/scsi/mpi3mr" "$moddir/drivers/scsi/libsas"; \
      rm -rf "$moddir/drivers/net/ethernet/mellanox" "$moddir/drivers/net/ethernet/amazon" "$moddir/drivers/net/ethernet/microsoft" "$moddir/drivers/net/ethernet/google" "$moddir/drivers/net/ethernet/intel"; \
      rm -rf "$moddir/drivers/net/bonding" "$moddir/drivers/net/wwan" "$moddir/drivers/net/wireguard" "$moddir/drivers/net/vxlan" "$moddir/drivers/net/team" "$moddir/drivers/net/hyperv" "$moddir/drivers/net/vmxnet3" "$moddir/drivers/net/xen-netback"; \
    done; \
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
