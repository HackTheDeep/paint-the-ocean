ifndef HACK_THE_DEEP_IMAGES_PATH
	HACK_THE_DEEP_IMAGES_PATH ?= $(shell bash -c 'read -p "Path to raw images: " pwd; echo $$pwd')
endif

RESIZE_DEPENDENCY_LOCK_FILE = .lock/.resize-dependencies
RESIZE_LOCK_FILE = .lock/.resize
CONVERT_TO_VIDEO_LOCK_FILE = .lock/.convert-to-video

RESIZE_IMAGE_DIRECTORY = ./resized
RESIZE_OUTPUT_IMAGE = resized/output-%04d.jpg
RESIZE_INPUT_IMAGE = $(HACK_THE_DEEP_IMAGES_PATH)/img-%04d.JPG

CONVERT_TO_VIDEO_FILE = scope_rip_1.mp4

all: resize convert-to-video
clean: resize-clean convert-to-video-clean

## Main Steps
resize: install
ifeq (,$(wildcard $(RESIZE_IMAGE_DIRECTORY)))
	@mkdir $(RESIZE_IMAGE_DIRECTORY)
endif
ifeq (,$(wildcard $(RESIZE_LOCK_FILE)))
ifndef HACK_THE_DEEP_IMAGES_PATH
	@echo "Path to raw images: "
	@read HACK_THE_DEEP_IMAGES_PATH
endif
	ffmpeg -i $(RESIZE_INPUT_IMAGE) -vf scale=2000:1500 $(RESIZE_OUTPUT_IMAGE)
	@touch $(RESIZE_LOCK_FILE)
else
	@echo "Skipping resize."
endif

convert-to-video: install
ifeq (,$(wildcard $(CONVERT_TO_VIDEO_LOCK_FILE)))
	ffmpeg -r 24 -f image2 -s 1000x750 -i $(RESIZE_OUTPUT_IMAGE) -vcodec libx264 -crf 25 -pix_fmt yuv420p $(CONVERT_TO_VIDEO_FILE)
	@touch $(CONVERT_TO_VIDEO_LOCK_FILE)
else
	@echo "Skipping converting to video."
endif

## Helpers
install:
ifeq (,$(wildcard $(RESIZE_DEPENDENCY_LOCK_FILE)))
	@echo "Downloading dependencies for resize..."
	brew install ffmpeg
	@touch $(RESIZE_DEPENDENCY_LOCK_FILE)
else
	@echo "Skipping dependency download."
endif

resize-clean:
	@echo "Cleaning up after resizing..."
	rm -r $(RESIZE_IMAGE_DIRECTORY)
	@rm $(RESIZE_LOCK_FILE)

convert-to-video-clean:
	@echo "Cleaning up after converting to video..."
	@rm $(CONVERT_TO_VIDEO_FILE)
	@rm $(CONVERT_TO_VIDEO_LOCK_FILE)
