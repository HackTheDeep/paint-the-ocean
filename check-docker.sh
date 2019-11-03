#!/bin/bash

if ! [ -x "$(command -v docker)" ]; then
    #brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve
    echo "Please make sure you install Docker for mac before proceeding"
    open https://docs.docker.com/docker-for-mac/install/
    exit 1
else
    exit 0
fi
