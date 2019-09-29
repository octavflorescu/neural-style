FROM nvidia/cuda:10.1-devel-ubuntu18.04
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

ENV CUDNN_VERSION 7.6.3.30
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda10.1 \
&& \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get -y install sudo curl wget software-properties-common git

# Install torch7
WORKDIR /root
RUN curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps
# https://github.com/torch/distro.git
RUN git clone https://github.com/nagadomi/distro.git ~/torch --recursive
WORKDIR /root/torch
RUN ~/torch/install-deps
RUN ~/torch/install.sh

# Install loadcaffe
RUN apt-get install -y libprotobuf-dev protobuf-compiler
RUN /root/torch/install/bin/luarocks install image
RUN /root/torch/install/bin/luarocks install loadcaffe

# Install neural-style
WORKDIR /root
RUN git clone --depth 1 https://github.com/jcjohnson/neural-style.git

# load models (about 500MB)
WORKDIR /root/neural-style
RUN bash models/download_models.sh

RUN ln -s /root/torch/install/bin/th /bin/th

COPY docker-entrypoint.sh /root/
ENTRYPOINT ["/root/docker-entrypoint.sh"]
#CMD ["/cron.sh"]
