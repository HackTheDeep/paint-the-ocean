FROM ubuntu

MAINTAINER Hector hector@hectorleiva.com

WORKDIR /app

COPY . ./

RUN apt-get update -qq && \
    apt-get install -y \
		wget \
        apt-utils \
        build-essential \
        sudo \
        git-core \
        cmake \
        yasm \
        nasm \
        automake \
        autoconf \
        libtool \
        pkg-config \
        texinfo \
        libass-dev \
        libcurl4-openssl-dev \
        libavcodec-extra57 \
        libx264-dev \
        intltool \
        libxml2-dev \
        libgtk2.0-dev \
        libnotify-dev \
        libglib2.0-dev \
        libevent-dev \
        zlib1g-dev \
        checkinstall

SHELL ["/bin/bash", "-c", "source setup.sh"]
