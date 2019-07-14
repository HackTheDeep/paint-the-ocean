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

ifndef HACK_THE_DEEP_IMAGES_PATH
	HACK_THE_DEEP_IMAGES_PATH ?= $(shell bash -c 'read -p "Path to raw images: " pwd; echo $$pwd')
endif

RESIZE_DEPENDENCY_LOCK_FILE = .lock/.resize-dependencies
RESIZE_LOCK_FILE = .lock/.resize
CONVERT_TO_VIDEO_LOCK_FILE = .lock/.convert-to-video
STABILIZE_VIDEO_DEPENDENCY_LOCK_FILE = .lock/.stabilize-video

RESIZE_IMAGE_DIRECTORY = ./resized
RESIZE_OUTPUT_IMAGE = resized/output-%04d.jpg
RESIZE_INPUT_IMAGE = $(HACK_THE_DEEP_IMAGES_PATH)/img-%04d.JPG

CONVERT_TO_VIDEO_FILE = scope_rip_1.mp4


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: resize convert-to-video stabilize-video ## Resize images, convert to video, and stabilize
clean: resize-clean convert-to-video-clean stabilize-video-clean ## Clean all temp files and unlock all commands

## Main Steps
resize: install-ffmpeg ## Resize images to a standardized size
ifeq (,$(wildcard $(RESIZE_IMAGE_DIRECTORY)))
	@mkdir $(RESIZE_IMAGE_DIRECTORY)
endif
ifeq (,$(wildcard $(RESIZE_LOCK_FILE)))
	ffmpeg -i $(RESIZE_INPUT_IMAGE) -vf scale=2000:1500 $(RESIZE_OUTPUT_IMAGE)
	@touch $(RESIZE_LOCK_FILE)
else
	@echo "Skipping resize."
endif

convert-to-video: install-ffmpeg ## Convert images to a video
ifeq (,$(wildcard $(CONVERT_TO_VIDEO_LOCK_FILE)))
	ffmpeg -r 24 -f image2 -s 1000x750 -i $(RESIZE_OUTPUT_IMAGE) -vcodec libx264 -crf 25 -pix_fmt yuv420p $(CONVERT_TO_VIDEO_FILE)
	@touch $(CONVERT_TO_VIDEO_LOCK_FILE)
else
	@echo "Skipping converting to video."
endif

stabilize-video: install-docker ## Stablize video

## Helpers
install-ffmpeg: ## Install ffmpeg
ifeq (,$(wildcard $(RESIZE_DEPENDENCY_LOCK_FILE)))
	brew install ffmpeg
	@touch $(RESIZE_DEPENDENCY_LOCK_FILE)
else
	@echo "Skipping resize dependency download."
endif

install-docker: ## Install docker
ifeq (,$(wildcard $(STABILIZE_VIDEO_DEPENDENCY_LOCK_FILE)))
	brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve
	@touch $(STABILIZE_VIDEO_DEPENDENCY_LOCK_FILE)
else
	@echo "Skipping stabilize video dependency download."
endif

resize-clean: ## Remove resize directory and unlock resizing
	@echo "Cleaning up after resizing..."
	rm -r $(RESIZE_IMAGE_DIRECTORY)
	@rm $(RESIZE_LOCK_FILE)

convert-to-video-clean: ## Unlock convert to video
	@echo "Cleaning up after converting to video..."
	@rm $(CONVERT_TO_VIDEO_FILE)
	@rm $(CONVERT_TO_VIDEO_LOCK_FILE)

stabilize-video-clean: ## Unlock video stabilization
	@echo "Cleaning up after stabilizing video..."
	@rm $(STABILIZE_VIDEO_DEPENDENCY_LOCK_FILE)