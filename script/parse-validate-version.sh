#!/bin/bash

VERSION="${GITHUB_REF#refs/tags/v}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]$ ]]; then
	echo "Version '$VERSION' in GITHUB_REF '$GITHUB_REF' is not a valid semver string"
	exit 1
fi
