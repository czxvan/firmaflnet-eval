FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# FirmAE deps
RUN apt-get update
RUN apt-get install -y apt-utils sudo \
        wget tar bc psmisc ruby telnet \
        socat net-tools iputils-ping iptables iproute2 curl \
        python3 python3-pip \
        libpq-dev \
        busybox-static bash-static fakeroot git kpartx netcat-openbsd nmap python3-psycopg2 snmp uml-utilities util-linux vlan \
        mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract fusecram cramfsswap squashfs-tools sleuthkit default-jdk cpio lzop lzma srecord zlib1g-dev liblzma-dev liblzo2-dev \
        python3-magic unrar fdisk python3-bs4 \
        graphviz-dev libcap-dev libssl-dev ninja-build libglib2.0-dev libfdt-dev libslirp-dev \
        qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils

RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install psycopg2 psycopg2-binary python-magic \
    && python3 -m pip install python-lzo cstruct ubi_reader coloredlogs

# for analyzer
RUN python3 -m pip install selenium bs4 requests future paramiko pysnmp pycryptodome

ENV USER=root
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspaces/firmaflnet-repro

# Below may need proxy.
RUN python3 -m pip install git+https://github.com/sviehb/jefferson
RUN git clone https://github.com/czxvan/FirmAFLNet FirmAFLNet
RUN cd FirmAFLNet && \
    git clone --recursive https://github.com/pr0v3rbs/FirmAE.git
RUN cd FirmAFLNet/FirmAE && \
    git clone https://github.com/ReFirmLabs/binwalk.git && \
    git clone https://github.com/czxvan/sasquatch.git && \
    cd ../qemu_mode && \
    wget https://download.qemu.org/qemu-6.2.0.tar.xz && \
    cd ..

COPY build.sh .
COPY extract_one.sh .
COPY run_experiment.sh .
RUN ./build.sh

ENV LANGUAGE="en_US.UTF-8"
ENV LANG=en_US:zh_CN.UTF-8
ENV LC_ALL=C
ENV PGPASSWORD=firmadyne

ENTRYPOINT /bin/bash
