#!/bin/bash
DIR="$(dirname "$(readlink -f "$0")")"
FAN_ROOT="${DIR}/FirmAFLNet"

export USER=`whoami`
service postgresql start

echo -n "[*] Waiting for postgresql database to become available ...";
while true; do
    psql -U firmadyne -h 127.0.0.1 -d firmware -c 'select 1' > /dev/null 2>/dev/null && break
    echo -n "."
    sleep 1
done
echo " done!"

experiment_id=$1


# Mapping between experiment ids to firmadyne-sample ids
declare -A id_mapping=(
        ["3473"]="3473"     # R6300v2_V1.0.2.72_1.0.46 armel httpd https://www.downloads.netgear.com/files/GDC/R6300V2/R6300v2_V1.0.2.72_1.0.46.zip
        ["9050"]="9050"     # DIR-815  httpd
        ["9054"]="9054"     # DIR-817LW httpd
        ["bmc-https"]="bmc-https"       # OpenBmc hello-crows
        ["bmc-http"]="bmc-http"         # OpenBmc hello-crow
)


# Mapping between experiment ids to FirmAFL samples
# This is required because the FirmAFL and firmadyne sample name differs
declare -A sample_mapping=(
        ["3473"]="arm/R6300v2_V1.0.2.72_1.0.46.zip"
        ["9050"]="mipsel/DIR-815_FIRMWARE_1.01.ZIP"
        ["9054"]="mips/DIR-817LW_REVA_FIRMWARE_1.00B05.ZIP"
)

image_id=${id_mapping[$experiment_id]}
image_filename=${sample_mapping[$experiment_id]}


if [[ ${image_id} == "" ]]; then
    echo "Supplied ${experiment_id} does not have a backing image, exiting"
    exit -1
fi

if [[ ${image_id} =~ "bmc" ]]; then
    rm -r FirmAFLNet/image_${image_id} >& /dev/null
    echo "[+] create image_${image_id}"
    cp -r FirmAFLNet/FirmAFLNet_config/${image_id} FirmAFLNet/image_${image_id}
    exit 0;
fi

echo "[+] Cleaning up previously unpacked images"
cd ${FAN_ROOT}
rm -r ./image_${experiment_id} >& /dev/null
rm -r ./image_${image_id} >& /dev/null

cd ${FAN_ROOT}/FirmAE
rm ./images/${image_id}.tar.gz >& /dev/null
rm ./images/${image_id}.kernel >& /dev/null
rm -r ./scratch/${image_id} >& /dev/null

echo "[+] Extracting image and checking network"
cd ${FAN_ROOT}/FirmAE
./run.sh -c auto ${FAN_ROOT}/firmware/${image_filename}

cd ${FAN_ROOT}
echo "[+] FAN setup for image_${image_id}/"
python3 FAN_setup.py ${image_id}
echo "[+] generate image_${image_id}/"
python3 generate_run_fan.py ${image_id}

cd ${FAN_ROOT}
echo "[+] Setting up experiment ${experiment_id} (image id: ${image_id})"
if [ ${experiment_id} != ${image_id} ]; then
    cp -r ${FAN_ROOT}/image_${image_id} ./image_${experiment_id}
fi

cp -r ${FAN_ROOT}/FirmAFLNet_config/${experiment_id}/* ./image_${experiment_id}/
rm ./image_${experiment_id}/seed