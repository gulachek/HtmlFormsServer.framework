#!/bin/bash

set -ex

# First build HtmlFormsServer.framework
xcodebuild

# Now create xcframework
if [ -e HtmlFormsServer.xcframework ]; then
	rm -rf HtmlFormsServer.xcframework
fi

xcodebuild -create-xcframework \
	-framework build/Release/HtmlFormsServer.framework \
	-output HtmlFormsServer.xcframework

# Make sure we've included licenses
for RES in HtmlFormsServer.xcframework/*/HtmlFormsServer.framework/RESOURCES; do
	test -f "$RES/LICENSE"
	DEP="$RES/DEPENDENCY-LICENSES"
	test -f "$DEP/boost.txt"
	test -f "$DEP/cJSON.txt"
	test -f "$DEP/catui.txt"
	test -f "$DEP/html_forms.txt"
	test -f "$DEP/html_forms_server.txt"
	test -f "$DEP/libarchive.txt"
	test -f "$DEP/msgstream.txt"
	test -f "$DEP/unixsocket.txt"
	test -f "$DEP/zlib.txt"
done

# Now test basic Swift package referencing above
cd testpkg
swift run
