#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_VERSION=$CROWD_VERSION

docker network create crowd_dockertestnet

source $CUR_DIR/testImage.sh latest
source $CUR_DIR/testImage.sh $TEST_VERSION
