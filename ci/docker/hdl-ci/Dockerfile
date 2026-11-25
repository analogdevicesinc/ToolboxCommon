# HDL CI image for ADI MATLAB toolboxes (MATLAB + Vivado mounted from host).
#
# Equivalent to tfcollins/hdl-ci, rebased on Ubuntu 22.04: Vivado 2025.1+
# does not support Ubuntu 20.04, and Vivado crashed in the 20.04 image with
# glibc heap corruption ("realloc(): invalid pointer") when launching runs.
#
# MATLAB and Vivado are NOT installed in the image; CI mounts them read-only:
#   -v /opt/MATLAB:/opt/MATLAB:ro -v /opt/Xilinx:/opt/Xilinx:ro
FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/analogdevicesinc/ToolboxCommon"
LABEL org.opencontainers.image.description="HDL CI image for ADI MATLAB toolboxes"
LABEL org.opencontainers.image.licenses="BSD-3-Clause"

ENV XLNX_INSTALL_LOCATION=/opt/Xilinx
ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    # Build tools and numeric libraries
    build-essential gfortran libpng-dev libfreetype6-dev libblas-dev liblapack-dev \
    # X11 / virtual display
    xorg xvfb libgtk2.0-0 libxss1 libxt6 \
    # Java
    openjdk-8-jre openjdk-8-jdk \
    # General utilities
    ca-certificates zip unzip curl wget tar git file rsync cpio bc screen \
    python-is-python3 python3-pip iputils-ping sudo net-tools iproute2 procps \
    # Kernel / boot file tooling
    fakeroot libncurses5-dev libssl-dev ccache dfu-util u-boot-tools \
    device-tree-compiler mtools \
    # Vivado runtime dependencies
    libtinfo5 libncurses5 lib32stdc++6 libicu70 libicu-dev \
    # MATLAB R2025b runtime dependencies (Ubuntu 22.04)
    libasound2 libc6 libcairo2 libcairo-gobject2 libcap2 libcups2 libdrm2 \
    libfontconfig1 libgbm1 libgdk-pixbuf-2.0-0 libgl1 libglib2.0-0 \
    libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libgtk-3-0 libice6 \
    libnspr4 libnss3 libpam0g libpango-1.0-0 libpangocairo-1.0-0 \
    libpangoft2-1.0-0 libsndfile1 libudev1 libuuid1 libwayland-client0 \
    libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxft2 libxinerama1 \
    libxrandr2 libxtst6 libxxf86vm1 zlib1g make \
    # Locale
    locales \
 && echo "dash dash/sh boolean false" | debconf-set-selections \
 && dpkg-reconfigure dash \
 && locale-gen en_US.UTF-8 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

COPY docker-entrypoint-hdl.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["/bin/bash"]
