FROM julia:1.0-stretch

COPY src/install_pylon.sh /project/src/install_pylon.sh
RUN bash /project/src/install_pylon.sh
ENV PYLON_INCLUDE_PATH /opt/pylon5/include
ENV PYLON_LIB_PATH /opt/pylon5/lib64

COPY . /project
WORKDIR /project
RUN bash src/build.sh

CMD julia --project samples/init.jl
