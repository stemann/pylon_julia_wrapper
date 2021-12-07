#!/bin/sh

install_pylon_on_debian()
{
    apt-get update
    apt-get install -y apt-utils

    DEBIAN_FRONTEND=noninteractive apt-get install -y usbutils cmake clang

    PYLON_VERSION=6.3.0.23157
    PYLON_SHA1SUM=e34ce2d18afda78611ba1d761b375a5d0ebd212a

    TIME_LIMIT=`echo $(($(date +%s) + 24*60*60))`
    curl https://www.baslerweb.com/fp-${TIME_LIMIT}/media/downloads/software/pylon_software/pylon_${PYLON_VERSION}-deb0_amd64.deb -O
    echo "${PYLON_SHA1SUM} pylon_${PYLON_VERSION}-deb0_amd64.deb" | sha1sum -c
    DEBIAN_FRONTEND=noninteractive dpkg -i pylon_${PYLON_VERSION}-deb0_amd64.deb
    rm -f pylon_${PYLON_VERSION}-deb0_amd64.deb
    export PATH=/opt/pylon/bin:$PATH
    export PYLON_INCLUDE_PATH=/opt/pylon/include
    export PYLON_LIB_PATH=/opt/pylon/lib
}

install_pylon_on_debian
