#! /usr/bin/env zsh #-x

SCRIPT_NAME=${0:t}
SCRIPT_DIR=${0:h}

function print_usage_and_exit {
    echo "usage: ${SCRIPT_NAME} <release> <arm64|x86_64>, for example: ${SCRIPT_NAME} 98.0 arm64"
    exit $1
}

if [ $# -ne 2 ]; then
    print_usage_and_exit 1 
fi

set -e

RELEASE_VERSION="$1"
ARCHITECTURE="$2"

if [[ ${ARCHITECTURE} != "arm64" ]] && [[ ${ARCHITECTURE} != "x86_64" ]]; then
    print_usage_and_exit 2
fi

NEXT_REVISION_DIR=${SCRIPT_DIR}/next-package-revision
RELEASE_TAG=release-${RELEASE_VERSION}
DMG_REVISION_FILE=${NEXT_REVISION_DIR}/${RELEASE_TAG}-${ARCHITECTURE}.txt

if [[ ! -f ${DMG_REVISION_FILE} ]]; then
    echo ${SCRIPT_NAME}: ${DMG_REVISION_FILE} must exist before release ${RELEASE_VERSION} can be published
    exit 2
fi

dmg_revision=$(<${DMG_REVISION_FILE})
let dmg_revision=${dmg_revision}+1
echo ${dmg_revision} > ${DMG_REVISION_FILE}

echo Next revision of ${DMG_REVISION_FILE:t} is now ${dmg_revision}