#!/bin/bash
set -e
set -u
ROOT_DIR=$(realpath $(dirname ${0}))
source ${ROOT_DIR}/facts.sh

# Removes xhost access and docker container
function cleanUp() {

  # If possible remove xhost access
  if [[ ${1} != '' ]]; then
    xhost -local:${1} > /dev/null
  fi

  # Wait for the container to start running.
  #
  # If the container has not entered state 'running' before the sleep is over
  # the container will be force-removed before even getting a chance of
  # running in the first place. Depending on the situation this may be
  # desirable.
  sleep 1

  # Wait for the container to stop running. The container should stop when the
  # application (Eclipse IDE) is closed by the user or crashes.
  while [[ $(docker inspect --format='{{.State.Status}}' ${2}) == 'running' ]]; do
    sleep .1
  done

  # Ungracefully remove the container.
  # The removal is forced to prevent the container to become a zombie due to
  # unforeseen errors.
  docker container rm -f "${2}" > /dev/null
}

# Ensure that any zombie is removed prior to start
# Might become dangerous if started multiple times?
#cleanUp '' "${containerName}"

# Build. Ensure that we're running the latest stuff.
#${ROOT_DIR}/build.sh

containerName='eclipse-ide'

# Create the container to be able to retrieve its hostname for xhost later on.
containerId=$(docker create \
  --name "${containerName}" \
  --env="DISPLAY=${DISPLAY}" \
  --volume='/tmp/.X11-unix:/tmp/.X11-unix:rw' \
  --volume="${HOME}:${HOME}" \
  ${DOCKER_IMAGE})

# Get container's hostname for xhost access later on.
containerHostname=$(docker inspect --format='{{ .Config.Hostname }}' "${containerId}")

# Enable trap to ensure cleanup after us.
trap 'cleanUp "${containerHostname}" "${containerName}"' ERR EXIT

# Allow access to xhost for container's application.
xhost +local:${containerHostname} > /dev/null

# Actually start the application.
docker start "${containerId}" > /dev/null
