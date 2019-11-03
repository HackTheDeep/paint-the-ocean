.PHONY: help

NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32;01m
ERROR_COLOR=\x1b[31;01m
WARN_COLOR=\x1b[33;01m

BLACK_COLOR=\x1b[30m
RED_COLOR=\x1b[31m
GREEN_COLOR=\x1b[32m
YELLOW_COLOR=\x1b[33m
BLUE_COLOR=\x1b[34m
MAGENTA_COLOR=\x1b[35m
CYAN_COLOR=\x1b[36m
WHITE_COLOR=\x1b[37m
RESET_COLOR=\x1b[0m

# Docker Commands
CURRENT_DIR=$(shell pwd)
DOCKER_IMAGE_NAME="paint_the_ocean"
DOCKER_CONTAINER_NAME="pto"
HOST_VOLUME="media_drive"

RESIZE_IMAGE_DIRECTORY = ./resized
RESIZE_OUTPUT_IMAGE = resized/output-%04d.jpg

CONVERT_TO_VIDEO_FILE = scope_rip_1.mp4

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: resize convert-to-video stabilize-video ## Resize images, convert to video, and stabilize
clean: resize-clean convert-to-video-clean stabilize-video-clean ## Clean all temp files and unlock all commands

.PHONY: start
start: .docker-installation .build-docker

.docker-installation:
	./check-docker.sh && touch $@

.build-docker:
	docker build -t ${DOCKER_IMAGE_NAME} . && \
		touch $@ && \
			docker run --name ${DOCKER_CONTAINER_NAME} \
			-v ${CURRENT_DIR}/${HOST_VOLUME}:/app/${HOST_VOLUME} \
			-it ${DOCKER_IMAGE_NAME} \
			/bin/bash

.PHONY: destroy
destroy:
	docker rm ${DOCKER_CONTAINER_NAME} && \
	docker rmi ${DOCKER_IMAGE_NAME} && \
	rm -f .build-docker

.PHONY: enter
enter: .build-docker
	docker start ${DOCKER_CONTAINER_NAME} && \
		docker attach ${DOCKER_CONTAINER_NAME}
