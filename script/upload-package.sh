#!/bin/sh

set -e
set -x

XCF=HtmlFormsServer.xcframework
ZIP="HtmlFormsServer.zip"

if [ ! -e "$XCF" ]; then
	echo "$XCF doesn't exist. Cannot upload"
	exit 1
fi

zip -r "$ZIP" "$XCF"
test -e "$ZIP"

# Validates and sets VERSION
. script/parse-validate-version.sh

gh release upload "v$VERSION" "$ZIP#Binary xcframework (zip)"
