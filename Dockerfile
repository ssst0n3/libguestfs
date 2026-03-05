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
    mv /tmp/virt-sparsify /usr/bin/virt-sparsify; \
    rm -rf /etc/virt-builder; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

CMD ["virt-sparsify", "--help"]
