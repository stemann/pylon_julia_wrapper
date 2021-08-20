#!/bin/sh

install_pylon_on_debian()
{
    apt-get update
    apt-get install -y apt-utils

    DEBIAN_FRONTEND=noninteractive apt-get install -y usbutils cmake clang

    PYLON_VERSION=5.1.0.12682
    PYLON_SHA1SUM=2e051aa9e6470dc22eeb6069514c845f3dff4752

    #PYLON_VERSION 5.2.0.13457
    #PYLON_SHA1SUM 4886c00219226e7f3334bd580c8c37791422cc41

    TIME_LIMIT=`echo $(($(date +%s) + 24*60*60))`
    curl https://www.baslerweb.com/fp-${TIME_LIMIT}/media/downloads/software/pylon_software/pylon_${PYLON_VERSION}-deb0_amd64.deb -O
    echo "${PYLON_SHA1SUM} pylon_${PYLON_VERSION}-deb0_amd64.deb" | sha1sum -c
    DEBIAN_FRONTEND=noninteractive dpkg -i pylon_${PYLON_VERSION}-deb0_amd64.deb
    rm -f pylon_${PYLON_VERSION}-deb0_amd64.deb
    export PATH=/opt/pylon5/bin:$PATH
    export PYLON_INCLUDE_PATH=/opt/pylon5/include
    export PYLON_LIB_PATH=/opt/pylon5/lib64
}

install_pylon_on_debian
