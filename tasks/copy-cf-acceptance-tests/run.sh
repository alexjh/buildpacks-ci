#!/bin/bash -l

set -o errexit
set -o nounset
set -o pipefail

echo "Extracting cf-acceptance-tests from cf-release"

pushd cf-release
    git submodule update --init --recursive src/github.com/cloudfoundry/cf-acceptance-tests/
popd

rsync -a cf-release/src/github.com/cloudfoundry/cf-acceptance-tests/ cf-acceptance-tests/
