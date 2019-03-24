#!/bin/bash -x

set -o errexit    # abort script at first error

function testImage() {
  local tagname=$1
  local iteration=0
  docker run -d --network crowd_dockertestnet --name=crowd.$tagname atldocker/crowd:$tagname
  while ! docker run --rm --network crowd_dockertestnet atldocker/jenkins-swarm curl http://crowd.$tagname:8095
  do
      { echo "Exit status of curl (${iteration}): $?"
        echo "Retrying ..."
      } 1>&2
      if [ "$iteration" = '30' ]; then
        exit 1
      else
        iteration=$((iteration+1))
      fi
      sleep 10
  done
  docker stop crowd.$tagname
}

testImage $1
