#!/bin/bash
#Script to download ffmpeg components and compile ffmpeg from source
#All versions current as of 08/19/14

exec &>> ~/ffmpeg-compiler.log
#Install packages for dependencies
sudo yum install -y autoconf automake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel
#Install packages that are available from yum
sudo yum install -y libogg libogg-devel libvpx libvpx-devel libvorbis libvorbis-devel yasm yasm-devel
sudo mkdir /usr/local/ffmpeg_sources


#Yasm: Yasm is an assembler used by x264 and FFmpeg
# cd /usr/local/ffmpeg_sources
# sudo curl -O http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
# sudo tar xzvf yasm-1.2.0.tar.gz
# cd yasm-1.2.0
# sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin"
# sudo make
# sudo make install
# sudo make distclean
# . ~/.bash_profile

#x264: H.264 video encoder
cd /usr/local/ffmpeg_sources
sudo git clone --depth 1 git://git.videolan.org/x264
cd x264
sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --enable-static
sudo make
sudo make install
sudo make distclean

#libfdk_aac: AAC audio encoder
cd /usr/local/ffmpeg_sources
sudo git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
sudo autoreconf -fiv
sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared
sudo make
sudo make install
sudo make distclean

#libmp3lame: MP3 audio encoder
cd /usr/local/ffmpeg_sources
sudo curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
sudo tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared --enable-nasm
sudo make
sudo make install
sudo make distclean

#libopus: Opus audio decoder and encoder
# cd /usr/local/ffmpeg_sources
# sudo curl -O http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz
# sudo tar xzvf opus-1.0.3.tar.gz
# cd opus-1.0.3
# sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared
# sudo make
# sudo make install
# sudo make distclean

#libogg: Ogg bitstream library. Required by libtheora and libvorbis
# cd /usr/local/ffmpeg_sources
# sudo curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
# sudo tar xzvf libogg-1.3.1.tar.gz
# cd libogg-1.3.1
# sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared
# sudo make
# sudo make install
# sudo make distclean

#libvorbis: Vorbis audio encoder. Requires libogg.
# cd /usr/local/ffmpeg_sources
# sudo curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.gz
# sudo tar xzvf libvorbis-1.3.3.tar.gz
# cd libvorbis-1.3.3
# sudo ./configure --prefix="/usr/local/ffmpeg_build" --with-ogg="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared
# sudo make
# sudo make install
# sudo make distclean

#libvpx: VP8/VP9 video encoder.
# cd /usr/local/ffmpeg_sources
# sudo git clone --depth 1 http://git.chromium.org/webm/libvpx.git
# cd libvpx
# sudo ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-examples
# sudo make
# sudo make install
# sudo make clean

#And finally, FFmpeg
cd /usr/local/ffmpeg_sources
sudo git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
PKG_CONFIG_PATH="/usr/local/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH
sudo ./configure --prefix="/usr/local/ffmpeg_build" --extra-cflags="-I/usr/local/ffmpeg_build/include" --extra-ldflags="-L/usr/local/ffmpeg_build/lib" --bindir="/usr/local/bin" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-libvorbis --enable-libvpx --enable-libx264
sudo make
sudo make tools/qt-faststart
sudo cp -a tools/qt-faststart /usr/bin/
sudo make install
sudo make distclean
hash -r
. ~/.bash_profile

#QT-Faststart Installation if it failed above
#cd /usr/local/ffmpeg_sources/ffmpeg
#sudo ./configure
#sudo make
#sudo make tools/qt-faststart
#sudo cp -a tools/qt-faststart /usr/bin/