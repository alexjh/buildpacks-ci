#!/bin/bash -l

set -o errexit
set -o nounset
set -o pipefail

pushd buildpacks-ci
  # shellcheck disable=SC1091
  source ./bin/target_bosh "$DEPLOYMENT_NAME"
popd

pushd cflinuxfs2-rootfs-release
  ./scripts/generate-bosh-lite-manifest
  cp manifests/bosh-lite/rootfs-smoke-test.yml "../buildpacks-ci/deployments/$DEPLOYMENT_NAME/"
popd

rsync -a buildpacks-ci/deployments/ rootfs-smoke-test-manifest-artifacts
