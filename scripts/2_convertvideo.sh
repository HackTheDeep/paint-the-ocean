#!/bin/bash

#
# Step Two:
#   Taking all the images that were created from Step One, we will assemble
#   them together and convert them into a video that will be used to restablize.
#

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Only the path to the directory of sequential images is required, you provided $# We need something like /path/to/images/"

current_time=$(date "+%Y.%m.%d-%H.%M.%S")

mkdir -p /app/media_drive/videos/

OUTPUT_PATH="/app/media_drive/videos/converted_images_to_video.${current_time}.mp4"

ffmpeg -r 24 -f image2 \
    -i "$1/output-%04d.jpg" \
    -vcodec libx264 \
    -crf 25 \
    -pix_fmt yuv420p \
    ${OUTPUT_PATH}

return $OUTPUT_PATH

