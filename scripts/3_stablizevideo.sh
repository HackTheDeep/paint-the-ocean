#!/bin/bash

#
# Step Three:
#   After generating the video from Step Two, this will apply all the transformation
#   and stablization to the video itself and creating a final video. This video
#   is what will be used for OpenCV for additional processing.
#

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Only the path to the input video is required, you provided $#"

mkdir -p /app/media_drive/videos/
current_time=$(($(date +%s%N)/1000000))

# First, we are generating a file that contains the stablization data necessary for the stable version of the video
ffmpeg -i $1 \
    -vf vidstabdetect=shakiness=10:accuracy=15:result="transforms.trf" \
    -f null - && \
# Second, take the file generated and create a new stablized version of the video
ffmpeg -i $1 \
    -vf vidstabtransform=zoom=5:input="transforms.trf" \
    /app/media_drive/clip-stablizied_${current_time}.mp4 && \
# Thirdly, delete the transformation data, it is no longer required
rm /app/transforms.trf
