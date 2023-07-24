#!/usr/bin/env bash

# Autodyne
# CompSec Direct
# Version 0.5a
# Author: Charles Boyd, DJ Forbes, jfersec
# Date: Jun 19 2020
# Desired Invocation: ./autodyne-0.5a.sh foo samples/1.bin // where foo is the manufacturer and samples/1.bin is relative path to files
# Docker invocation: docker run --privileged -v /home/ubuntu/samples:/opt/firmadyne/samples -v /home/ubuntu/sample-out:/opt/firmadyne/sample-out/ -dit firmadyne /opt/firmadyne/autodyne-0.5a.sh

args=("$@")
Manufacturer=${1}
FW=/opt/firmadyne/samples/${2}
BASENAME=$(basename $FW)
FPATH=/opt/firmadyne

echo "Changing Directory..."
cd /opt/firmadyne
echo "Setting $Manufacturer for $FW"
echo "Here is basename $BASENAME"

setup() {

    if [ -f /etc/autodyne-cfg.sh ];
    then
        . /etc/autodyne-cfg.sh
    else
        echo "WARN: no config file to load at /etc/autodyne-cfg.sh"
    fi

    #check if a pgpass file is set, if not, create it
    if [ -f "/root/.pgpass" ];
    then
        echo "Pass is already set, continuing...."
    else
        #echo "*.*.*.*.:firmadyne" >> /root/.pgpass
        echo "*:*:*:firmadyne:firmadyne" >> /root/.pgpass
        echo "*:*:*:firmadyne:firmadyne" >> /home/firmadyne/.pgpass
        chmod 600 /root/.pgpass
        PGPASSFILE=/root/.pgpass
    fi

    if [ ! -f ${FW} ];
    then
        echo "${FW} does not exist or is not readable, exiting"
        exit -1
    fi

    if [ -z ${Manufacturer} ];
    then
        "Manufacturer not provided."
        $Manufacturer=unknown
    fi
}

run_extractor() {
    python3 ./sources/extractor/extractor.py -b $Manufacturer -sql ${FIRMADYNE_POSTGRES_HOST} -np -nk "$FW" images | tee /opt/firmadyne/samples-out/$BASENAME-extractor-output
}

get_image_id() {
    local ImageID=$(grep "Database Image ID:" /opt/firmadyne/sample-out/$BASENAME-extractor-output | cut -d: -f2 | sed 's/ //g')

    if [[ "$ImageID" -lt 0 ]]; then
        echo "Did not read in ImageID"
        echo $ImageID
        exit
    fi

    echo $ImageID
}

get_arch() {
    local ImageID=$1
    local DefaultArch=mipseb

    local ReadArch=$(./scripts/getArch.sh $FPATH/images/${ImageID}.tar.gz | tee /opt/firmadyne/sample-out/$BASENAME-getArch-output)

    local Arch=$(echo ${ReadArch} | cut -d: -f2 | sed 's/ //g')

    if [ ! -z "$Arch" ]; then
        echo "successfully inferred architecture"
        echo "$Arch"
    else
        echo "default architecture guessed"
        echo "$DefaultArch"
    fi
}

tar2db() {
    local ImageID=$1
    ./scripts/tar2db.py -i $ImageID -f $FPATH/images/${ImageID}.tar.gz
}

make_image() {
    local ImageID=$1
    local Arch=$(./scripts/getArch.sh ./images/${ImageID}.tar.gz | cut -d: -f2 | sed -e 's/ //g')
    # store make image output for creation of docker image
    ./scripts/makeImage.sh $ImageID $Arch | tee /opt/firmadyne/sample-out/$BASENAME-makeImage-output
}

infer_network() {
    local ImageID=$1
    local Arch=$(./scripts/getArch.sh ./images/${ImageID}.tar.gz | cut -d: -f2 | sed -e 's/ //g')
    ./scripts/inferNetwork.sh $ImageID $Arch | tee /opt/firmadyne/sample-out/$BASENAME-inferNetwork-output
    local NICS=$(grep "Interfaces:" /opt/firmadyne/sample-out/$BASENAME-inferNetwork-output | cut -d: -f2 | cut -d, -f2 | sed 's/)]//g' | sed "s/'//g" | sed 's/ //g')
    # store nic info for scanning
    echo $NICS
}

start_emulator() {
    local ImageID=$1
    tmux new-session -d -s "ImageID $ImageID" ./scratch/$ImageID/run.sh
    tail -f /dev/null
}

process_firmware() {
    local ImageID=$(get_image_id)
    local Arch=$(get_arch ${ImageID})

    echo "ImageID: $ImageID"
    echo "Arch: $Arch"

    echo "Extracting filesystem and building QEMU image for sample $ImageID..."
    tar2db $ImageID && make_image $ImageID $Arch && infer_network $ImageID $Arch

    echo "starting emulator for sample $ImageID..."
    start_emulator $ImageID
}


setup && run_extractor && process_firmware
