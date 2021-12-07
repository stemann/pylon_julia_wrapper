FROM julia:1.6-buster

COPY src/install_pylon.sh /project/src/install_pylon.sh
RUN bash /project/src/install_pylon.sh
ENV PYLON_INCLUDE_PATH /opt/pylon/include
ENV PYLON_LIB_PATH /opt/pylon/lib

COPY . /project
WORKDIR /project
RUN bash src/build.sh

CMD julia --project samples/init.jl
