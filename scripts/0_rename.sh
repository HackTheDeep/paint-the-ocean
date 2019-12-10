#!/bin/bash

# A helper script in case any of the files we are trying to work with need to have
# their file extensions lowercased

SEARCH_DIR=$1

find "./$1" -name "*.JPEG" -type f | while read -r f; do mv "$f" "${f/.JPEG/._jpg}"; done

find "./$1" -name "*.JPG" -type f | while read -r f; do mv "$f" "${f/.JPG/._jpg}"; done

find "./$1" -name "*._jpg" -type f | while read -r f; do mv "$f" "${f/._jpg/.jpg}"; done

