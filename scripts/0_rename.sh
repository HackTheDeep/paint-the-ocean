#!/bin/bash

# A helper script in case any of the files we are trying to work with need to have
# their file extensions lowercased

for i in *.JPEG;
do
    mv "$i" "${i/.JPEG/.jpg}"
done

for i in *.JPG;
do
    mv "$i" "${i/.JPG/.jpg}"
done
