FROM --platform=linux/amd64 debian:bookworm-slim

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
      guestfs-tools; \
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

CMD ["virt-sparsify", "--help"]
