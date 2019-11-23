#!/bin/bash

#
# Step One:
#   Resize all the images within a directory to ensure that they are all the same
#   size and smaller than what the camera was able to capture. We had raw images
#   that were at least 4k in resolution and that would have taken a long time to
#   do additionally processing.
#
#   After this, all the images are also renamed with a trailing "-0000" number
#   sequence. This is in order to make it easier to reassemble these images together
#   using ffmpeg.
#

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Only the path to the directory of sequential images is required, you provided $# We need something like /path/to/images/"

OUTPUT_PATH="/app/media_drive/resized"

./0_rename.sh $1

mkdir -p $OUTPUT_PATH

ffmpeg -pattern_type glob \
    -i "$1/*.jpg" \
    -vf "scale=iw/2:ih/2" \
    $OUTPUT_PATH/output-%04d.jpg

return $OUTPUT_PATH
