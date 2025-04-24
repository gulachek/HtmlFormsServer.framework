#!/bin/bash

set -e
set -x

. script/util.sh

SRC="$PWD"
DEP_LICENSES="$SRC/DEPENDENCY-LICENSES"

BOOST_DOWNLOAD="$VENDORSRC/download-boost.tgz"

download \
	-u "https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.gz" \
	-c "f55c340aa49763b1925ccf02b2e83f35fdcf634c9d5164a2acb87540173c741d" \
	-o "$BOOST_DOWNLOAD"
	
BOOST="$VENDORSRC/boost"
md "$BOOST"

untar -f "$BOOST_DOWNLOAD" -d "$BOOST"
cp "$BOOST/LICENSE_1_0.txt" "$DEP_LICENSES/boost.txt"

cd "$BOOST"
./bootstrap.sh --prefix="$VENDOR" --with-libraries=headers
./b2 install

cd "$SRC"
rm -rf "$BOOST"
rm "$BOOST_DOWNLOAD"

cd "$SRC"
