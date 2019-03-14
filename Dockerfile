FROM julia:1.0-stretch

RUN apt-get update
RUN apt-get install -y apt-utils

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y usbutils cmake clang

ENV PYLON_VERSION 5.1.0.12682
ENV PYLON_SHA1SUM 2e051aa9e6470dc22eeb6069514c845f3dff4752

#ENV PYLON_VERSION 5.2.0.13457
#ENV PYLON_SHA1SUM 4886c00219226e7f3334bd580c8c37791422cc41

WORKDIR /root
RUN export TIME_LIMIT=`echo $(($(date +%s) + 24*60*60))` && curl https://www.baslerweb.com/fp-${TIME_LIMIT}/media/downloads/software/pylon_software/pylon_${PYLON_VERSION}-deb0_amd64.deb -O
RUN echo "${PYLON_SHA1SUM} pylon_${PYLON_VERSION}-deb0_amd64.deb" | sha1sum -c
RUN DEBIAN_FRONTEND=noninteractive dpkg -i pylon_${PYLON_VERSION}-deb0_amd64.deb
RUN rm -f pylon_${PYLON_VERSION}-deb0_amd64.deb
ENV PATH /opt/pylon5/bin:$PATH

ENV PYLON_INCLUDE_PATH /opt/pylon5/include
ENV PYLON_LIB_PATH /opt/pylon5/lib64

COPY . /project
WORKDIR /project
RUN julia --eval 'using Pkg; pkg"activate ."; pkg"instantiate"'
RUN export CxxWrap_PATH=`julia --eval 'import Pkg; Pkg.activate("."); import CxxWrap; println(joinpath(dirname(pathof(CxxWrap)), ".."))'`\
  && rm -rf build && mkdir -p build\
  && cd build\
  && cmake ../src -DCMAKE_FIND_ROOT_PATH=${CxxWrap_PATH}/deps/usr/lib/cmake -DPYLON_INCLUDE_PATH=${PYLON_INCLUDE_PATH} -DPYLON_LIB_PATH=${PYLON_LIB_PATH}\
  && make

CMD julia --eval 'import Pkg; Pkg.activate("."); include("samples/init.jl")'
