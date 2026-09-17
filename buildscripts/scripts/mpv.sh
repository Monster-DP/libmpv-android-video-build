#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

# libmpv links with the C driver (mpv is C-only) but pulls in C++
# objects (harfbuzz, fftools_ffi). Statically link the C++ runtime
# or dlopen fails at runtime with unresolved __gxx_personality_v0.
meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
 	-Dlua=disabled \
 	-Dcplayer=false \
	-Diconv=disabled \
	-Dvulkan=disabled \
	-Daaudio=disabled \
	-Dmanpage-build=disabled \
	-Dc_link_args=-lc++_static,-lc++abi,-lunwind

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
