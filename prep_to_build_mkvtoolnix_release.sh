#! /usr/bin/env zsh #-x
SCRIPT_NAME=${0:t}
SCRIPT_DIR=${0:h}

if [ $# -ne 1 ]; then
    echo "usage: ${SCRIPT_NAME} <release>, for example: ${SCRIPT_NAME} 98.0"
    exit 1
fi

RELEASE_VERSION="$1"
DMG_REVISION_FILE="dmg-revision.txt"

set -e

DMG_REVISION=$(< ${SCRIPT_DIR}/${DMG_REVISION_FILE})
if [[ -z ${DMG_REVISION} ]]; then
    echo "The DMG revision to build must be specified in ./${DMG_REVISION_FILE}"
    exit 2
fi

RELEASE_TAG="release-${RELEASE_VERSION}"
RELEASE_DIR=${SCRIPT_DIR}/${RELEASE_TAG}
git clone -c advice.detachedHead=false \
    --depth 1 --branch ${RELEASE_TAG} \
    https://codeberg.org/mbunkus/mkvtoolnix \
    ${RELEASE_DIR}

echo "Creating config.local.sh"
PACKAGING_DIR=${RELEASE_DIR}/packaging/macos
cat <<EOF > ${PACKAGING_DIR}/config.local.sh
export SIGNATURE_IDENTITY="Developer ID Application: Graham Thompson (H4MM26UAYB)"
export NOTARY_PROFILE="NotaryProfile"
export DRAKETHREADS=$(sysctl -n hw.logicalcpu)
export DMG_REVISION=${DMG_REVISION}
EOF

QT_PATCH_DIR=${SCRIPT_DIR}/qt-patches
if [[ -d ${QT_PATCH_DIR} ]]; then
    echo "Adding QT patches..."
    RELEASE_QT_PATCH_DIR=${PACKAGING_DIR}/qt-patches
    mkdir -p ${RELEASE_QT_PATCH_DIR}
    for patch in ${QT_PATCH_DIR}/*.patch; do
        echo "copying $(basename ${patch}) ready for build.sh"
        cp ${patch} ${RELEASE_QT_PATCH_DIR}/
    done
fi

MACOS_PATCH_DIR=${SCRIPT_DIR}/macos-patches
if [[ -d ${MACOS_PATCH_DIR} ]]; then
    echo "Applying packaging/macos patches..."
    for patch in ${MACOS_PATCH_DIR}/*.patch; do
        ${MACOS_PATCH_DIR}/patch.sh ${PACKAGING_DIR} ${patch}
    done
fi

echo
echo "You're ready to build revision ${DMG_REVISION} of the release ${RELEASE_VERSION} DMG, using:"
echo
echo "    cd ./${RELEASE_TAG}/packaging/macos"
echo "    ./build.sh"
echo "    ./build.sh dmg"
echo
