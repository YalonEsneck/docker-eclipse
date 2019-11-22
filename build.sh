#!/bin/bash
set -e
ROOT_DIR=$(dirname ${0})
source ${ROOT_DIR}/facts.sh

uid=$(id --user)
gid=$(id --group)

if [[ $uid == $(id --user root) ]]; then
  echo "You are attempting to build Eclipse IDE as $(whoami)."
  echo "You should not run this script as $(whoami)!"
  echo "Quitting now because otherwise all files created by Eclipse IDE would be owned by $(whoami)!"
  exit 0
else
  echo "Building Eclipse IDE as ${uid}:${gid}."
fi

docker build "${ROOT_DIR}" --tag="${DOCKER_IMAGE}"
