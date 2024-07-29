#!/bin/bash
export USER=`whoami`

DIR="$(dirname "$(readlink -f "$0")")"

experiment_id=$1
target_dir="${DIR}/FirmAFLNet/image_${experiment_id}"


if [ $# -lt 1 ]; then
    echo "Usage: $0 <experiment_id> [seconds]"
    echo -e "\t Will fuzz experiment with specified id for n seconds."
    echo -e "\t Default value for seconds: 86400"
    exit -1
fi

fuzz_seconds=${2:-86400}


if [ ! -d "${target_dir}" ] 
then
    echo "It seems experiment ${experiment_id} was not extracted, doing so now" 
    $DIR/extract_one.sh ${experiment_id}
fi

cd ${target_dir}
fuzz_seconds_adjusted=$(($fuzz_seconds+160))
timeout $fuzz_seconds_adjusted ./run_fan.sh