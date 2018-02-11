# Paint the Ocean
#### Team
- [Alex Keyes](https://github.com/Alex-Keyes)
- [Hector Leiva](https://github.com/hectorleiva)
- [Shelby Rackley](https://github.com/srackley)
- [Erika Samuels](https://github.com/e-r-i-k-a)
- [Joseph Spens](https://github.com/josephspens)

## Technologies Used
- Python 🐍
- [Matplotlib](https://matplotlib.org/)
- [OpenCV](https://opencv.org/)
- FFMPEG 🎥
- [Hugin](http://hugin.sourceforge.net/)

## Cleaning Up the Images
The collection of images that we were given were separated into 3 zipped files. Each zip that contained images had roughly two "unbroken" spans of time where it was easier to track the spill of the dye before some time would pass and "skip in time" to the next sequence of images.

What we ended up doing in order to obtain the best stabilization was to contain these sequences as separate "films" or "batches" of images.

We used the following command to generate a movie of the images within each zipped archive to quickly check roughly around how long each sequence of images were before they "skipped in time":
```
ffmpeg -r 30 -f image2 -s 1000x750 -i SCOPE\ rip\ dye\ 12\ dec13_1/img-%04d.JPG -vcodec libx264 -crf 25 -pix_fmt yuv420p scope_rip_1.mp4
```

After reviewing the movie and then manually determining where to split up the images into batches, we needed to lower the file size of each image to be able to perform any stablization process over them for the sake of time.

The following runs through the raw images, scales them down to 2000x1500 (the same ratio as the raw images) and outputs them into a `resized` directory with the output files maintaining the same numbering.
```
ffmpeg -i SCOPE\ rip\ dye\ 12\ dec13_1/img-%04d.JPG -vf scale=2000:1500 resized/output-%04d.jpg
```

### Generating mini-"films" per batch of images
While we were able to maintain the numbering system that was used in the images as they were photographed, we were unable to maintain that numbering system to generate _each batch of images_ into films. This was due to our limitation with `ffmpeg` and that tool needing to start from *0001* everytime it would process images and convert them into movies.

We would use a bash script that would take say the first batch within the second zipped file, and rewrite those numbers starting at 0001 and counting up to the total number of images:
```
#!/bin/bash
a=1
for file in *.jpg
    do
        new=$(printf "output-%04d.jpg" "$a")
        mv -i -- "$file" "$new"
        let a=a+1
    done
```

After this is done, then we would target these files and render these specifically as movies:
```
ffmpeg -f image2 -s 1000x750 -i 2-batch-resized-334_527/movie_files/output-%04d.jpg -vcodec libx264 -crf 25 -pix_fmt yuv420p 2-batch-resized-334_527.mp4
```

A total of 5 movies would be generated (one for each batch of images that were an unbroken amount of time).

### Separating the work from here

Since now we had a smaller resolution collection of images of the "batches" and "films" of the batches as well, the video was passed to one part of the team to stablize the video, and the images were passed to the rest of the team to run OpenCV to attempt to isolate and filter for just the colored dye in the water.

## Video stablization
TBD

## OpenCV
TBD

