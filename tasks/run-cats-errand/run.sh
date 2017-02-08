#!/bin/bash -l

set -e


DOMAIN_NAME=${DOMAIN_NAME:-cf-app.com}
bosh_target=$DEPLOYMENT_NAME.$DOMAIN_NAME

bosh target $bosh_target
bosh login $BOSH_USER $BOSH_PASSWORD

manifest_dir=$(mktemp -d -t manifestXXX)

pushd $manifest_dir
	bosh download manifest cf-warden cf.yml
	bosh deployment cf.yml
popd

if [ "$DIEGO_DOCKER_ON" = "true" ]
then
  cf api api.$DEPLOYMENT_NAME.$DOMAIN_NAME --skip-ssl-validation
  cf login -u $CI_CF_USERNAME -p $CI_CF_PASSWORD
  cf enable-feature-flag diego_docker
fi

bosh run errand acceptance_tests

if [ "$DIEGO_DOCKER_ON" = "true" ]
then
  cf disable-feature-flag diego_docker
fi

