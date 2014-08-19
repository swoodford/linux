#!/bin/bash
#Script to download ffmpeg components and compile ffmpeg from source
#All versions current as of 08/19/14

exec &>> ffmpeg-compiler.log
#Install packages for dependencies
sudo yum install -y autoconf automake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel
mkdir ~/ffmpeg_sources


#Yasm: Yasm is an assembler used by x264 and FFmpeg
cd ~/ffmpeg_sources
sudo curl -O http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
sudo tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
sudo ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
sudo make
sudo make install
sudo make distclean
. ~/.zprofile

#x264: H.264 video encoder
cd ~/ffmpeg_sources
sudo git clone --depth 1 git://git.videolan.org/x264
cd x264
sudo ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
sudo make
sudo make install
sudo make distclean

#libfdk_aac: AAC audio encoder
cd ~/ffmpeg_sources
sudo git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
sudo autoreconf -fiv
sudo ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
sudo make
sudo make install
sudo make distclean

#libmp3lame: MP3 audio encoder
cd ~/ffmpeg_sources
sudo curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
sudo tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
sudo ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
sudo make
sudo make install
sudo make distclean

#libopus: Opus audio decoder and encoder
cd ~/ffmpeg_sources
sudo curl -O http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
sudo tar xzvf opus-1.1.tar.gz
cd opus-1.1
sudo ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
sudo make
sudo make install
sudo make distclean

#libogg: Ogg bitstream library. Required by libtheora and libvorbis
cd ~/ffmpeg_sources
sudo curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
sudo tar xzvf libogg-1.3.2.tar.gz
cd libogg-1.3.2
sudo ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
sudo make
sudo make install
sudo make distclean

#libvorbis: Vorbis audio encoder. Requires libogg.
cd ~/ffmpeg_sources
sudo curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
sudo tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
sudo ./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
sudo make
sudo make install
sudo make distclean

#libvpx: VP8/VP9 video encoder.
cd ~/ffmpeg_sources
sudo git clone --depth 1 http://git.chromium.org/webm/libvpx.git
cd libvpx
sudo ./configure --prefix="$HOME/ffmpeg_build" --disable-examples
sudo make
sudo make install
sudo make clean

#And finally, FFmpeg & QT-Faststart
cd ~/ffmpeg_sources
sudo git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH
sudo ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264
sudo make
sudo make tools/qt-faststart
sudo cp -a tools/qt-faststart /usr/bin/
sudo make install
sudo make distclean
hash -r
. ~/.zprofile

#QT-Faststart Installation if it failed above
#cd ~/ffmpeg_sources/ffmpeg
#sudo ./configure
#sudo make
#sudo make tools/qt-faststart
#sudo cp -a tools/qt-faststart /usr/bin/
