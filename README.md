# Painting the Ocean
Challenge URL: https://github.com/amnh/HackTheDeep/wiki/Painting-the-Ocean

![demo-gif](demo.gif)

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
Our team was given a collection of images separated into 3 zipped files. Each file contained approximately 300 drone images taken of dye releases along a Florida beach from December 2013.

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

## Post-Hackathon Improvements

Hector went ahead and created an isolated Docker container that will process all the photo/video work as listed above. Here are the steps for anyone starting out with this project:

0. Clone this repository into your local machine
```
git clone git@github.com:HackTheDeep/paint-the-ocean.git
```

1. Make sure you have Docker installed on your machine: https://docs.docker.com/docker-for-mac/install/ | This needs to be installed ahead of time before we can truly start anything.

2. You will notice an empty directory called `media_drive/` for this project. This directory is where all the image processing will occur and it'll be our volume.

3. Copy over the images that we will be processing into the `media_drive/`. The images should be in a folder/directory, and every image should be a JPG image. If they are any other format, this process won't work for now.

4. 

*The following is all automated and will take some time to build on your machine.*

```
make start
```

This will immediately start building out the Docker container. It will create a container on your machine, install everything nescessary to do all the image processing work, and you will immediately be pushed into this Docker container after it is done installing.

5. You should now be inside the Docker container.

This environment has all of the necessary software you'll need to be able to process your images to render a stablized video that you will need to use to then run the Python OpenCV program against.

If you type out `ls -la`, you should see all of the same folders that were within the repoistory you just cloned with a few additions like `libs/` for example.

Run the command `source setup.sh` to finish setting up the container properly.

6. Remember where you placed your images, we will be referencing that location to process the following scripts.

You can double-check where they are by typing `ls -la media_drive/` and locate them that way from inside the Docker container

7. Execute the following, making sure that you've replaced `<images-folder-name-here>` with the location of where they are within the `media_drive/`. We are looking for the folder that contains just the images themselves.
```
./convert_images_to_stablized_video.sh media_drive/<image-folder-name-here>/<all-image-files-here>
```

8. The script will be excuting the following:
`0_rename.sh` - Makes sure that if for any chance the files have `.JPG` named in their extension OR `.JPEG` - that they are transformed to `.jpg` to make it easier for the work later on.

`1_resizeimages.sh` - Makes sure that all the images are halved in size. The images we were dealing with during the hackathon were too high in resolution to be able to process the video stablization and OpenCV work later on.
This creates a folder within `media_drive/resized` that will contain all of the resized images in sequencial order.

`2_convertvideo.sh` - Converts the sequence of images that have been resized into a single video, this video will be in `media_drive/videos` and called something like `converted_images_to_video` and have a timestamp of when this was accomplished.

`3_stablizevideo.sh` - Will take the video entitled `converted_images_to_video` from the `media_drive` and stablizes it. The stablized video will exist within the `media_drive` and be called something like `clip-stablized`.

9. After this is done, you should now be able to access the stablized video from within the `media_drive/videos`. You will now reference this video for the OpenCV processing.

10. You can now exist this container by typing `exit` at any time. The container will exit as well and "turn off"

11. If for any reason you need to re-enter the container to do additional work, you can type
```
make enter
```

and this should restart the container and you'll jump into it as before

12. Once you feel like all the work for image/video stablization has been completed, feel free to delete this container via the command:
```
make destroy
```

This will completely destroy the container and anything that you've installed within it. This `media_drive/` will be left completely alone and on your system. So any converted images/videos, those will remain on your system as before.
