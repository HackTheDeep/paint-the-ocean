# Painting the Ocean
https://github.com/amnh/HackTheDeep/wiki/Painting-the-Ocean

## Team
- [Alex Keyes](https://github.com/Alex-Keyes)
- [Hector Leiva](https://github.com/hectorleiva)
- [Shelby Rackley](https://github.com/srackley)
- [Erika Samuels](https://github.com/e-r-i-k-a)
- [Joseph Spens](https://github.com/josephspens)

## Technologies Used
- Python 🐍
- [OpenCV](https://opencv.org/)
- VidStab
- FFMPEG 🎥
- Docker

## Cleaning Up the Images
Our team was given a collection of images separated into 3 zipped files. Each file contained approximately 300 drone images taken of dye releases along Florida beach coasts from December 2013.

We received the images in order that they were captured, and wanted to stitch the together into a movie to observe the growth of the spill.  In order to produce a clear, stable image, we batched images.

We used the following command to generate a movie of images within each zipped archive to check how long each image batch was before it skipped in time:

```
ffmpeg -r 30 -f image2 -s 1000x750 -i SCOPE\ rip\ dye\ 12\ dec13_1/img-%04d.JPG -vcodec libx264 -crf 25 -pix_fmt yuv420p scope_rip_1.mp4
```

After reviewing the movie and manually determining where to split up the images into batches, we lessened the file size of each image to more easily stabilize the images in a short amount of time.

The following code runs through the raw images, scales them down to 2000x1500 (the same ratio as the raw images) and outputs them into a `resized` directory with the output files maintaining the same numbering.

```
ffmpeg -i SCOPE\ rip\ dye\ 12\ dec13_1/img-%04d.JPG -vf scale=2000:1500 resized/output-%04d.jpg
```

### Generating mini-"films" per batch of images
While we were able to maintain the numbering system that was used in the images as they were photographed, we were unable to maintain that numbering system to generate _each batch of images_ into films. This was due to our limitation with `ffmpeg` and that tool starting from *0001* everytime it processed images and converted them into movies.

In the future, we would like to use a bash script that would take say the first batch within the second zipped file, and rewrite those numbers starting at 0001 and count up to the total number of images, for example:

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

Then, we would target these files and render them specifically as movies:
```

ffmpeg -f image2 -s 1000x750 -i 2-batch-resized-334_527/movie_files/output-%04d.jpg -vcodec libx264 -crf 25 -pix_fmt yuv420p 2-batch-resized-334_527.mp4
```

A total of 5 movies would be generated (one for each batch of images that were an unbroken amount of time).

### Separating the work from here
Since now we had a smaller resolution collection of images of the "batches" and "films" of the batches as well, the video was passed to one part of the team to stablize the video, and the images were passed to the rest of the team to run OpenCV to isolate and filter for just the colored dye in the water.

## Video stablization
To stabilize video, we needed to download and install Vidstab video stabilization library (which can be plugged-in with Ffmpeg).  The collection of "oil spill" photos, when stitched into a movie, were undesireably shakey and vidstab targets control points to help create smoother and more stable videos.

We downloaded FFmpeg (https://github.com/FFmpeg/FFmpeg) and vid.stab (https://github.com/georgmartius/vid.stab).

We originally thought we could use the native de-shake method in Ffmpeg, but later learned that we did not have enough control over the process, and instead opted to run Ffmpeg through an Ubuntu virtual environment in Docker.  (Vidstab is not normally included with Ffmpeg and it can only added using a Linux-based system.)

```
docker run \
 --name ubuntu \
 -e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
 -v /Users/username/Workspaces:/src \
 -t -i \
 ubuntu /bin/bash
Apt-get update
```
Dependencies are cmake, make, g++, yasm, nasm
```
cd vid.stab/
cmake .
make
make install
```

In order to integrate the Vidstab library, we had to configure Ffmpeg to enable the library (i.e. "--enable-libvidstab")

```
..cd
cd FFmpeg/
cmake .
./configure --enable-gpl --enable-libvidstab
make
make install
export LD_LIBRARY_PATH={/src/directory/}:$LD_LIBRARY_PATH
```

First we run a detection of the transformations that need to occur in order to stabilize the video, and then we apply them with the second command which results in an mpg output (stabilized file).

```
ffmpeg -i {./test_video.mp4} -vf vidstabdetect=shakiness=10:accuracy=15:result=”mytransforms1.trf” dummyoutput.mpg
ffmpeg -i {./test_video.mp4} -vf vidstabtransform=zoom=5:input=”mytransforms1.trf” stabilized_output.mpg
```

### Let's make a movie
After the movies were stablized individually, we stitched them together in order to see the entire result. Since the encoding was done differently on the stablization end and produced a different format, this is the command that was run to combine them:

```
ffmpeg -i "concat:out_stabilize1.mpg|out_stabilize2.mpg|out_stabilize3.mpg|out_stabilize4.mpg|out_stabilize5.mpg" final_stitched_video.mpg
```

To make a movie of all the resized images (before being stablized) to see the impact of our work:
```
ffmpeg -i 1-batch-1_333.mp4 -i 2-batch-334_527.mp4 -i 3-batch-528_769.mp4 -i 4-batch-770_903.mp4 -i 5-batch-904_1123.mp4 -filter_complex "[0:v:0] [1:v:0] [2:v:0] [3:v:0] [4:v:0] concat=n=5:v=1 [v]" -map "[v]" output_batch_stitched_video.mp4
```

Now we can compare `final_stitched_Video.mpg` vs. `output_batch_stitched_video.mp4`.

## OpenCV
OpenCV is used as the primary analysis tool on this project once the visual data has been sufficiently cleaned by the stabilization process described above. 
In this use case, computer vision can define solid boundaries of the increasing large oil slick, and add geometry as a helpful visual guide to
the development of the slick over time.  Additionally, defining a shape in OpenCV can be used to train a machine learning model in the future, 
allowing the creation of an accurate model of how we can expect oil to be dispersed in similar scenarios.

The analysis happens in 3 steps:
1. the stabilized video is streamed in as a opencv video object
`cam = cv2.VideoCapture('final_stablizied_stitched_video.mpg')`
2. RGB coloring is transformed into HSV coloring for better definition
`imgHSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)`
3. a Mask is created by defining an upper and lower bound for HSV colors 
```
    # create the Mask
    mask = cv2.inRange(imgHSV, lowerBound, upperBound)

    # morphology
    maskOpen = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernelOpen)
    maskClose = cv2.morphologyEx(maskOpen, cv2.MORPH_CLOSE, kernelClose)
    ```
4. the mask is transposed back onto the original stabilized video stream in order to create a defined geometric contour
```
    maskFinal = maskClose
    conts, h = cv2.findContours(maskFinal.copy(), cv2.RETR_EXTERNAL,
                                cv2.CHAIN_APPROX_NONE)

    cv2.drawContours(img, conts, -1, (255, 0, 0), 3)
    for i in range(len(conts)):
        x, y, w, h = cv2.boundingRect(conts[i])
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 0, 255))
```
