#!/bin/bash

set -e
set -x

. script/util.sh

CMAKE_ARCH="-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64"

cmake_build_install() {
	cmake --build build
	cmake --install build --prefix "$VENDOR"
	rm -rf build
}

SRC="$PWD"
DEP_LICENSES="$SRC/DEPENDENCY-LICENSES"

# zlib
ZLIB_DOWNLOAD="$VENDORSRC/download-zlib.tgz"
download \
	-u "https://zlib.net/zlib-1.3.1.tar.gz" \
	-c "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23" \
	-o "$ZLIB_DOWNLOAD"

ZLIB="$VENDORSRC/zlib"
md "$ZLIB"
untar -f "$ZLIB_DOWNLOAD" -d "$ZLIB"
cp "$ZLIB/LICENSE" "$DEP_LICENSES/zlib.txt"

cd "$ZLIB"
cmake -S . -B build \
	"$CMAKE_ARCH" \
	-DZLIB_BUILD_EXAMPLES=OFF \
	-DCMAKE_INSTALL_PREFIX="$VENDOR" \
	-DINSTALL_PKGCONFIG_DIR="$VENDOR/lib/pkgconfig"
cmake_build_install

rm "$ZLIB_DOWNLOAD"
for dylib in "$VENDOR"/lib/libz*.dylib; do
	if [ -f "$dylib" ]; then
		rm "$dylib"
	fi
done
for so in "$VENDOR"/lib/libz*.so; do
	if [ -f "$so" ]; then
		rm "$so"
	fi
done
cd "$SRC"

# cJSON
CJSON_DOWNLOAD="$VENDORSRC/download-cjson.tgz"
download \
	-u "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.18.tar.gz" \
	-o "$CJSON_DOWNLOAD" \
	-c "3aa806844a03442c00769b83e99970be70fbef03735ff898f4811dd03b9f5ee5"

CJSON="$VENDORSRC/cJSON"
md "$CJSON"

untar -d "$CJSON" -f "$CJSON_DOWNLOAD"
cp "$CJSON/LICENSE" "$DEP_LICENSES/cJSON.txt"

# cJSON CMakeLists.txt configures files that have full install paths. Must define prefix

cd "$CJSON"
cmake \
	"$CMAKE_ARCH" \
	-DENABLE_CJSON_TEST=OFF \
	-DBUILD_SHARED_LIBS=OFF \
	"-DCMAKE_INSTALL_PREFIX=$VENDOR" \
	-S . -B build
cmake_build_install

rm "$CJSON_DOWNLOAD"

# msgstream
MSGSTREAM_DOWNLOAD="$VENDORSRC/download-msgstream.tgz"
download \
	-u "https://github.com/gulachek/msgstream/releases/download/v0.3.2/msgstream-0.3.2.tgz" \
	-o "$MSGSTREAM_DOWNLOAD" \
	-c "5126ddd87fc61d0372aa7bb310be035ff18f76d1613e3784a7ac8f6b9a4940bb"

MSGSTREAM="$VENDORSRC/msgstream"
md "$MSGSTREAM"

untar -f "$MSGSTREAM_DOWNLOAD" -d "$MSGSTREAM"
cp "$MSGSTREAM/LICENSE.txt" "$DEP_LICENSES/msgstream.txt"

cd "$MSGSTREAM"
cmake -S . -B build "$CMAKE_ARCH"
cmake_build_install

rm "$MSGSTREAM_DOWNLOAD"

# unixsocket
UNIX_DOWNLOAD="$VENDORSRC/unixsocket-download.tgz"

download \
	-u "https://github.com/gulachek/unixsocket/releases/download/v0.1.1/unixsocket-0.1.1.tgz" \
	-o "$UNIX_DOWNLOAD" \
	-c "187244123c7dcbb6f96f52f126447321714658b5bd5cc41bc07338659f795c40"

UNIX="$VENDORSRC/unixsocket"
md "$UNIX"

untar -f "$UNIX_DOWNLOAD" -d "$UNIX"
cp "$UNIX/LICENSE.txt" "$DEP_LICENSES/unixsocket.txt"

cd "$UNIX"
cmake -S . -B build "$CMAKE_ARCH"
cmake_build_install

rm "$UNIX_DOWNLOAD"

# catui
CATUI_DOWNLOAD="$VENDORSRC/catui-download.tgz"

download \
	-u "https://github.com/gulachek/catui/releases/download/v0.1.3/catui-0.1.3.tgz" \
	-o "$CATUI_DOWNLOAD" \
	-c "3957d8249dcbc8fa6f8add23263cef7c7c0a3fb21bb3cf865316dcd8ff8c97bc"

CATUI="$VENDORSRC/catui"
md "$CATUI"

untar -f "$CATUI_DOWNLOAD" -d "$CATUI"
cp "$CATUI/LICENSE.txt" "$DEP_LICENSES/catui.txt"

cd "$CATUI"
cmake -DCMAKE_PREFIX_PATH="$VENDOR" "$CMAKE_ARCH" -S . -B build
cmake_build_install

rm "$CATUI_DOWNLOAD"

# html_forms
HTML_FORMS_DOWNLOAD="$VENDORSRC/html_forms-download.tgz"

download \
	-u "https://github.com/gulachek/html_forms/releases/download/v0.1.0/html_forms-0.1.0.tgz" \
	-o "$HTML_FORMS_DOWNLOAD" \
	-c "06511e9fb8a1e2e8ae175c765258336aa2a9ffad6de3d25c5dfa6e4949d7f43e"

HTML_FORMS="$VENDORSRC/html_forms"
md "$HTML_FORMS"

untar -f "$HTML_FORMS_DOWNLOAD" -d "$HTML_FORMS"
cp "$HTML_FORMS/LICENSE.txt" "$DEP_LICENSES/html_forms.txt"

cd "$HTML_FORMS"
cmake -DCMAKE_PREFIX_PATH="$VENDOR" "$CMAKE_ARCH" -S . -B build
cmake_build_install

rm "$HTML_FORMS_DOWNLOAD"

# html_forms_server
HTML_FORMS_SERVER_DOWNLOAD="$VENDORSRC/html_forms_server-download.tgz"

download \
	-u "https://github.com/gulachek/html_forms/releases/download/v0.1.0/html_forms_server-0.1.0.tgz" \
	-o "$HTML_FORMS_SERVER_DOWNLOAD" \
	-c "56ffd03e30d2db91b4e090968a641ab82513da56b36d1a0b0221d7178396410b"

HTML_FORMS_SERVER="$VENDORSRC/html_forms_server"
md "$HTML_FORMS_SERVER"

untar -f "$HTML_FORMS_SERVER_DOWNLOAD" -d "$HTML_FORMS_SERVER"
cp "$HTML_FORMS_SERVER/LICENSE.txt" "$DEP_LICENSES/html_forms_server.txt"

cd "$HTML_FORMS_SERVER"
cmake -DCMAKE_PREFIX_PATH="$VENDOR" "$CMAKE_ARCH" -S . -B build
cmake_build_install

rm "$HTML_FORMS_SERVER_DOWNLOAD"
