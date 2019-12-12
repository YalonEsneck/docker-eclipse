#!/bin/bash
set -e
set -u
ROOT_DIR=$(realpath $(dirname ${0}))
source ${ROOT_DIR}/facts.sh

# Ensure that the tmp files directory exists for the application's icon
mkdir -p ${FILES_TMP_DIR}

# Get the icon file and dump it into tmp files directory
containerId=$(docker create ${DOCKER_IMAGE})
docker cp ${containerId}:/opt/eclipse/icon.xpm ${FILES_TMP_DIR}/${DOCKER_TAG}.xpm
docker rm -f ${containerId} > /dev/null

cat <<EOF > "${HOME}/.local/share/applications/eclipse-${DOCKER_TAG}.desktop"
[Desktop Entry]
Name=Eclipse - ${DOCKER_TAG}
Type=Application
Exec=${ROOT_DIR}/run.sh ${DOCKER_TAG}
Terminal=false
Icon=${FILES_TMP_DIR}/${DOCKER_TAG}.xpm
Comment=Integrated Development Environment
NoDisplay=false
Categories=Development;IDE
Name[en]=Eclipse - ${DOCKER_TAG}
EOF
