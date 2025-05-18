FROM debian:12-slim
LABEL maitaners="Nochum Linczewski<linchevs@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
RUN \
        apt-get update && \
        apt-get install -yq curl python3 git wget xz-utils lz4 file \
                            bzip2 cpio diffstat gawk locales \
                            \
                            sudo build-essential git vim \
                            python3-yaml libncursesw5 \
                            man bash diffstat gawk chrpath wget cpio \
                            texinfo lzop apt-utils bc screen libncurses5-dev locales \
                            libc6-dev doxygen libssl-dev dos2unix xvfb x11-utils \
                            g++-multilib libssl-dev zlib1g-dev \
                            libtool libtool-bin procps python3-distutils pigz socat \
                            zstd iproute2 lz4 iputils-ping \
                            libtinfo5 net-tools xterm rsync u-boot-tools unzip zip \
                            \
                            cscope

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo && chmod a+x /bin/repo
RUN groupadd agl -g 1000 && \
    useradd -ms /bin/bash -p agl agl  -u 1028 -g 1000 && \
    usermod -aG sudo agl && \
    echo "agl:agl" | chpasswd

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.utf8
USER agl

WORKDIR /home/agl
RUN mkdir ./downloads \
          ./deploy

RUN git config --global user.email "linchevs@gmail.com" && git config --global user.name "Nochum Linczewski"

WORKDIR /home/agl/salmon
RUN   /bin/repo init -b salmon -m salmon_19.0.0.xml -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo && \
      /bin/repo sync

WORKDIR /home/agl/salmon/external/poky
RUN /home/agl/salmon/external/poky/scripts/install-buildtools
COPY rcfile.sh ./
RUN mkdir -p ./build-lincz/conf
COPY ./conf/bblayers.conf ./build-lincz/conf/
COPY ./conf/local.conf ./build-lincz/conf/

CMD ["bash", "--rcfile", "./rcfile.sh"]
