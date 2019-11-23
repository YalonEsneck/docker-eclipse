#!/bin/bash
export FILES_CONFIG_DIR="${ROOT_DIR}/files/config"
export FILES_TMP_DIR="${ROOT_DIR}/files/tmp"
export FILES_VOLUME_DIR="${ROOT_DIR}/files/volumes"
export GIT_BRANCH=$(git -C ${ROOT_DIR} rev-parse --abbrev-ref HEAD)
export DOCKER_TAG=${GIT_BRANCH}
if [[ ${GIT_BRANCH} = 'master' ]]; then export DOCKER_TAG='latest'; fi
export DOCKER_IMAGE="eclipse:${DOCKER_TAG}"
