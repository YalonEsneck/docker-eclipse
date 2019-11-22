#!/bin/bash
set -e
set -u
ROOT_DIR=$(dirname ${0})
source ${ROOT_DIR}/facts.sh

function cleanUp() {
  xhost -local:${1} > /dev/null
  docker container rm -f "${2}" > /dev/null
}

containerName='debug-eclipse'

containerId=$(docker create \
  --interactive \
  --tty \
  --name "${containerName}" \
  --env="DISPLAY=${DISPLAY}" \
  --entrypoint="bash" \
  --volume='/tmp/.X11-unix:/tmp/.X11-unix:rw' \
  ${DOCKER_IMAGE})

containerHostname=$(docker inspect --format='{{ .Config.Hostname }}' "${containerId}")
trap 'cleanUp "${containerHostname}" "${containerName}"' ERR

xhost +local:${containerHostname} > /dev/null
docker start --attach --interactive "${containerId}" ${@}

cleanUp "${containerHostname}" "${containerName}"
