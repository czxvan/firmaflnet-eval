#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"
FirmAE_DIR=$DIR/FirmAFLNet/FirmAE

cd $DIR/FirmAFLNet
cp  FirmAE_modify/firmae.config FirmAE/firmae.config
cp  FirmAE_modify/install.sh    FirmAE/install.sh
cp  FirmAE_modify/makeImage.sh  FirmAE/scripts/makeImage.sh
cp  FirmAE_modify/preInit.sh    FirmAE/scripts/preInit.sh

# =====================FirmAFLNet=============================
cd $DIR
echo "[*] Building firmaflnet afl-fuzz"
cd $DIR/FirmAFLNet
make

echo "[*] Building system mode spy_qemu"
cd $DIR/FirmAFLNet/qemu_mode/SPY_qemu_8.2.91/
./configure \
    --target-list=mipsel-softmmu,mips-softmmu,arm-softmmu \
    --disable-werror && \
    make -j6

echo "[*] Building aflspy plugin"
cd $DIR/FirmAFLNet/qemu_mode/SPY_qemu_8.2.91/plugin_spy
make


# ======================FirmAE================================
echo "[*] Building FirmAE"
cd $FirmAE_DIR
./download.sh
cp ../FirmAE_modify/agent/spy_agent.* binaries/ && \
chmod +x ./install.sh && \
./install.sh

# binwalk
cd binwalk
sudo ./deps.sh --yes
reset
sudo python3 ./setup.py install
cd .. 

# sasquatch
echo "[|] Setting up Sasquatch Fork"
cd sasquatch
./build.sh
cd ..