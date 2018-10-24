#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly BUILD_VERSION=$CROWD_VERSION

source $CUR_DIR/buildImage.sh $BUILD_VERSION latest
source $CUR_DIR/buildImage.sh $BUILD_VERSION $BUILD_VERSION
