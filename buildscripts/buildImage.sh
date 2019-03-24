#!/bin/bash -x

set -o errexit    # abort script at first error

function buildImage() {
  local version=$1
  local tagname=$2
  docker build -t atldocker/crowd:$tagname --build-arg CROWD_VERSION=$version --build-arg BUILD_DATE=$(date +"%d/%m/%y-%T%z") -f Dockerfile .
}

buildImage $1 $2
