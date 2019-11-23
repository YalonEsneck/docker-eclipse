#!/bin/bash
set -e
set -u
ROOT_DIR=$(realpath $(dirname ${0}))
source ${ROOT_DIR}/facts.sh

function cleanUp() {
  sleep 1
  while [[ $(docker inspect --format='{{.State.Status}}' ${2}) == 'running' ]]; do
    sleep .1
  done
  xhost -local:${1} > /dev/null
  docker container rm -f "${2}" > /dev/null
}

containerName='eclipse-ide'

containerId=$(docker create \
  --name "${containerName}" \
  --env="DISPLAY=${DISPLAY}" \
  --volume='/tmp/.X11-unix:/tmp/.X11-unix:rw' \
  --volume="${HOME}:/home/eclipse" \
  ${DOCKER_IMAGE})

containerHostname=$(docker inspect --format='{{ .Config.Hostname }}' "${containerId}")
trap 'cleanUp "${containerHostname}" "${containerName}"' ERR

xhost +local:${containerHostname} > /dev/null
docker start "${containerId}"

cleanUp "${containerHostname}" "${containerName}" &
