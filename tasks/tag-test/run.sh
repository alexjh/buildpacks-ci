#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

pushd buildpack
	echo "test-tag" >> "test.txt"
	git add test.txt
	git commit -m "Adding a test tag file"
	git tag "vtest-tag"
popd

rsync -a buildpack/ buildpack-output
