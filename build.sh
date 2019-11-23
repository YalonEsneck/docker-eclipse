#!/bin/bash
set -e
ROOT_DIR=$(realpath $(dirname ${0}))
source ${ROOT_DIR}/facts.sh

# Get user's UID and GID in order to replicate both in the container
# This is important because all files Eclipse creates will be owned by the
# here given user/group. This ensures that the user will have full access
# independent of root and/or the container.
uid=$(id --user)
gid=$(id --group)

# Check and warn if user is root
if [[ $uid == $(id --user root) ]]; then
  echo "You are attempting to build Eclipse IDE as $(whoami)."
  echo "You should not run this script as $(whoami)!"
  echo "Quitting now because otherwise all files created by Eclipse IDE would be owned by $(whoami)!"
  exit 0
else
  echo "Building Eclipse IDE as ${uid}:${gid}."
fi

docker build "${ROOT_DIR}" \
  --tag="${DOCKER_IMAGE}" \
  --build-arg UID=${uid} \
  --build-arg GID=${gid}
