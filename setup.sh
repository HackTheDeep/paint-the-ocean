#!/bin/bash

cd /app/
mkdir libs/ && cd libs/

echo "Beginning to install Vid.Stab. A video library used to stablized videos..."
# Install Vid.Stab for stablization
git clone https://github.com/georgmartius/vid.stab.git && \
    cd vid.stab/ && \
        cmake . && \
        make -j4 && \
        make install

# We need to ensure that the shell knows where to find the libraries
echo "LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64" >> ~/.profile
echo "export LD_LIBRARY_PATH" >> ~/.profile

echo "Vid.Stab installation was successful (1/2)"

echo "Beginning to install FFmpeg for all video stablization and video creation..."

cd ../ && \
	wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
	tar xjvf ffmpeg-snapshot.tar.bz2 && \
	cd ffmpeg && \
		PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
		  --prefix="$HOME/ffmpeg_build" \
		  --pkg-config-flags="--static" \
		  --extra-cflags="-I$HOME/ffmpeg_build/include" \
		  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
		  --extra-libs="-lpthread -lm" \
		  --bindir="$HOME/bin" \
		  --enable-gpl \
		  --enable-libvidstab \
		  --enable-libx264 && \
		PATH="$HOME/bin:$PATH" make && \
		make install && \
		hash -r

# Add FFmpeg into the PATH
echo "PATH=\"$HOME/bin:$PATH\"" >> ~/.profile

echo "FFmpeg installation was successful (2/2)"

# Success!
cat << EOM
Everything seems like it was installed successfully! 🙌

You will now be inserted into the docker container, to return back into it, run:

make enter

and you'll jump back into the container. Good Luck!
EOM

# Ensure these new options are sourced in the bashrc file
source ~/.profile

# Return back to the root directory
cd /app
