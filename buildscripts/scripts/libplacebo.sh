#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

# glad (GL loader generator) and its jinja deps live as git submodules;
# make sure they exist even if the clone was not done with --recursive
git submodule update --init --depth 1

# mpv 0.41+ requires libplacebo (vo_gpu removed, gpu-next/pl_opengl only).
# We only need the OpenGL backend for media_kit's render API, so disable
# vulkan and both SPIRV compilers (glslang/shaderc are vulkan-only codegen);
# this keeps libplacebo a pure-C library with zero extra dependencies.
meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	-Dvulkan=disabled \
	-Dvk-proc-addr=disabled \
	-Dopengl=enabled \
	-Dgl-proc-addr=enabled \
	-Dglslang=disabled \
	-Dshaderc=disabled \
	-Dd3d11=disabled \
	-Dlcms=disabled \
	-Ddovi=disabled \
	-Dlibdovi=disabled \
	-Dunwind=disabled \
	-Dxxhash=disabled \
	-Ddemos=false \
	-Dtests=false \
	-Dbench=false \
	-Dfuzz=false

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
