#! /usr/bin/env zsh #-x

SCRIPT_NAME=${0:t}
SCRIPT_DIR=${0:h}

if [ $# -ne 1 ]; then
    echo "usage: ${SCRIPT_NAME} <release>, for example: ${SCRIPT_NAME} 98.0"
    exit 1
fi

set -e

RELEASE_VERSION="$1"
RELEASE_TAG=release-${RELEASE_VERSION}

NEXT_REVISION_DIR=${SCRIPT_DIR}/next-package-revision
MACHINE=$(uname -m)
DMG_REVISION_FILE=${NEXT_REVISION_DIR}/${RELEASE_TAG}-${MACHINE}.txt

if [[ ! -f ${DMG_REVISION_FILE} ]]; then
    echo ${SCRIPT_NAME}: ${DMG_REVISION_FILE} must exist before release ${RELEASE_VERSION} can be published
    exit 2
fi

dmg_revision=$(<${DMG_REVISION_FILE})
let dmg_revision=${dmg_revision}+1
echo ${dmg_revision} > ${DMG_REVISION_FILE}

echo Next revision of ${DMG_REVISION_FILE:t} is now ${dmg_revision}