#!/bin/bash

if [ $# -ne 3 ]; then
    echo "usage: $0 <config_id> <num_iterations> <seconds_per_experiment>"
    exit 1
fi

config_id="$1"
num_iterations="$2"
seconds_per_experiment="$3"

echo "Config id: $config_id"
docker_image=firmaflnet
for i in $(seq 1 $num_iterations); do
    container_name="$docker_image-config-$config_id-run-$i-duration-$seconds_per_experiment"
    docker rm -f $container_name &>/dev/null
    docker run --privileged --name $container_name --entrypoint /workspaces/firmaflnet-repro/run_experiment.sh $docker_image $config_id $seconds_per_experiment
    # Give the fuzzer some time to bind to a core
    sleep 60
done

# AFL queue directory: /workspaces/firmaflnet-repro/FirmAFLNet/image_${config_id}/outputs
