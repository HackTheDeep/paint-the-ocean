#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Only the path to the directory of sequential images is required, you provided $# We need something like /path/to/images/"

scripts/0_rename.sh $1
RESIZE_IMAGES_PATH=$(scripts/1_resizeimages.sh $1)
CONVERTED_VIDEO_PATH=$(scripts/2_convertvideo.sh $RESIZE_IMAGES_PATH)
scripts/3_stablizevideo.sh $CONVERTED_VIDEO_PATH
