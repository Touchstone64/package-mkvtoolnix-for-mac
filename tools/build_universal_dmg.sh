#! /usr/bin/env zsh # -x

SIGNATURE_IDENTITY="Developer ID Application: Graham Thompson (H4MM26UAYB)"
NOTARY_PROFILE="NotaryProfile"

SCRIPT_NAME=${0:t}
SCRIPT_DIR=${0:h}

set -e

function exit_with_error_code {
    local rc=$1
    shift
    echo ${*} >&2
    exit ${rc}
}

function mount_dmg_and_get_volume_name {
    local dmg_file=${1}

    volume=$( hdiutil attach -puppetstrings ${dmg_file} | grep ^/dev | grep Apple_HFS | cut -f 3 )
    if [ ${volume[1,9]} != "/Volumes/" ]; then
        exit_with_error_code 10 "${dmg_file} not mounted into /Volumes/"
    fi

    echo ${volume}
}

function check_for_compatible_packages {
    local dmg1=${1}
    local dmg2=${2}

    local -a dmg1_spec dmg2_spec
    dmg1_spec=( $(echo ${dmg1:t:r} | awk -F- '{ print $1 "-" $2 " " $3 }' ) ) 
    dmg2_spec=( $(echo ${dmg2:t:r} | awk -F- '{ print $1 "-" $2 " " $3 }' ) ) 

    if [[ ${dmg1_spec[1]} != ${dmg2_spec[1]} ]]; then
        exit_with_error_code 20 "Cannot build universal app: release names don't match, ${dmg1_spec[1]} vs. ${dmg2_spec[1]}"
    fi

    if [[ ${dmg1_spec[2]} != ${dmg2_spec[2]} ]]; then
        exit_with_error_code 21 "Cannot build universal app: DMG revisions don't match, ${dmg1_spec[2]} vs. ${dmg2_spec[2]}"
    fi
}

function check_for_compatible_content { 
    # Package contents are considered compatible if their app names match
    # and the Info.plist files in those apps have the same content

    local dmg1=${1}
    local dmg2=${2}

    app1=$(get_app_from_dmg ${dmg1})
    app2=$(get_app_from_dmg ${dmg2})

    if [ ${app1:t} != ${app2:t} ]; then
        exit_with_error_code 30 "Cannot build universal app: ${app1:t} and ${app2:t} don't have the same name"
    fi

    plist1=${app1}/${CONTENTS_DIR}/${INFO_PLIST}
    if [ ! -f ${plist1} ]; then
        exit_with_error_code 31 "${INFO_PLIST} not found in ${app1}/${CONTENTS_DIR}"
    fi

    plist2=${app2}/${CONTENTS_DIR}/${INFO_PLIST}
    if [ ! -f ${plist2} ]; then
        exit_with_error_code 32 "${INFO_PLIST} not found in ${app2}/${CONTENTS_DIR}"
    fi

    set +e ; comparison=$( cmp ${plist1} ${plist2} ) ; set -e
    if [[ -n ${comparison} ]]; then
        exit_with_error_code 33 "Cannot build universal app: contents of ${INFO_PLIST} differ between ${app1} and ${app2}"
    fi
}

function get_app_from_dmg {
    local dmg=${1}
    local app=$( find ${dmg} -depth 1 -type d -iname "*.app" -print )
    if [[ ! -n ${app} ]]; then
        exit_with_error_code 40 "Cannot find *.app in ${dmg}"
    fi
    echo ${app}
}

function duplicate_files_but_not_directories {
    local from=${1}
    local to=${2}

    local -a files
    for entry (${from}/*) {
        if [[ -h ${entry} ]] || [[ ! -d ${entry} ]] files+=(${entry})
    }

    for file in ${files}; do
        cp -v -R ${file} ${to}
    done
}

function duplicate_non_mac_os_contents {
    local from=${1}
    local to=${2}

    local -a contents
    for file (${from}/*) {
        if [[ ${file:t} != ${MACOS_DIR} ]] contents+=(${file})
    }

    for content in ${contents}; do
        cp -v -R ${content} ${to}
    done
}

function test_file_exists_in_two_locations {
    local file=${1}
    local location1=${2}
    local location2=${3}

    if [ ! -f ${location1}/${file} ]; then
        echo "File not found: ${location1}/${file}"
        exit 10
    elif [ ! -f ${location2}/${file} ]; then
        echo "File not found: ${location2}/${file}"
        exit 11
    fi
}

function combine_executables {
    local arch1=${1}
    local arch2=${2}
    local universal=${3}

    local -a candidates links
    for file (${arch1}/*) {
        if [[ -f ${file} ]] candidates+=(${file})
        if [[ -h ${file} ]] links+=(${file})
    }

    for candidate in ${candidates}; do
        if [ -x ${candidate} ]; then
            executable=${candidate:t}
            test_file_exists_in_two_locations ${executable} ${arch1} ${arch2}
            echo "Creating universal binary for ${executable}"
            lipo ${arch1}/${executable} ${arch2}/${executable} -output ${universal}/${executable} -create
        else
            echo "Duplicating non-executable: ${candidate}"
            cp -v -R ${candidate} ${universal}/${candidate:t}
        fi
    done

    for link in ${links}; do
        cp -v -R ${link} ${universal}/${link:t}
    done

}

function combine_directories {
    local arch1=${1}
    local arch2=${2}
    local universal=${3}

    local -a dirs
    for file (${arch1}/*) {
        if [[ -d ${file} ]] dirs+=(${file})
    }

    for dir in ${dirs}; do
        leaf=${dir:t}
        echo "Universalising directory: ${leaf}"
        dylib_count=$( find ${dir} -iname "*.dylib" -type f -print | wc -l | tr -d ' ' )
        if [ ${dylib_count} -eq 0 ]; then
            cp -v -R ${arch1}/${leaf} ${universal}
        else
            mkdir -p ${universal}/${leaf}
            combine_executables ${arch1}/${leaf} ${arch2}/${leaf} ${universal}/${leaf}
        fi
    done
}

if [ $# -ne 3 ]; then
    echo "usage: ${SCRIPT_NAME} <DMG-1 path> <DMG-2 path> <universal path>"
    echo
    echo "If they are compatible, this script combines the binary content of two DMG"
    echo "packages, creating a signed and notarized package containing universal"
    echo "binaries in <universal path>. Non-binary artefacts will be copied from the"
    echo "DMG-1 package."
    echo
    echo "Packages are considered compatible if their app names match and the Info.plist"
    echo "files in those apps have the same content."
    exit 1
fi

set -x

APP_NAME=MKVToolNix
CONTENTS_DIR=Contents
INFO_PLIST=Info.plist
MACOS_DIR=MacOS

dmg1=${1:a}
dmg2=${2:a}
dmg_dir=${3:a}

if [ ! -f ${dmg1} ]; then
    exit_with_error_code 2 "DMG file not found: ${dmg1}"
fi

if [ ! -f ${dmg2} ]; then
    exit_with_error_code 3 "DMG file not found: ${dmg2}"
fi

check_for_compatible_packages ${dmg1} ${dmg2}

dmg_spec=( $(echo ${dmg1:t:r} | awk -F- '{ print $1 "-" $2 " " $3 }' ) )
universal_release=${dmg_spec[1]}
universal_revision=${dmg_spec[2]}

mkdir -p ${dmg_dir}

echo Attaching DMG volumes
DMG1_VOLUME=$(mount_dmg_and_get_volume_name ${dmg1})
DMG2_VOLUME=$(mount_dmg_and_get_volume_name ${dmg2})

trap "echo 'Detaching DMG volumes'; hdiutil detach '${DMG1_VOLUME}'; hdiutil detach '${DMG2_VOLUME}'" EXIT

check_for_compatible_content ${DMG1_VOLUME} ${DMG2_VOLUME}

WORK_DIR=~/tmp/compile/universal-dmg-${universal_release}-${universal_revision}
rm -rf ${WORK_DIR}
universal_app=${WORK_DIR}/${APP_NAME}.app
universal_contents=${universal_app}/${CONTENTS_DIR}
universal_macos=${universal_contents}/${MACOS_DIR}

echo "Creating ${universal_macos}"
mkdir -p ${universal_macos}

duplicate_files_but_not_directories ${DMG1_VOLUME} ${WORK_DIR}

dmg1_contents=$(get_app_from_dmg ${DMG1_VOLUME})/${CONTENTS_DIR}
dmg2_contents=$(get_app_from_dmg ${DMG2_VOLUME})/${CONTENTS_DIR}
duplicate_non_mac_os_contents ${dmg1_contents} ${universal_contents}

dmg1_macos=${dmg1_contents}/${MACOS_DIR}
dmg2_macos=${dmg2_contents}/${MACOS_DIR}
combine_executables ${dmg1_macos} ${dmg2_macos} ${universal_macos}
combine_directories ${dmg1_macos} ${dmg2_macos} ${universal_macos}

if [[ -n ${SIGNATURE_IDENTITY} ]]; then
    typeset -a non_executables
    for FILE (${universal_contents}/**/*(.)) {
        if [[ ${FILE} != */MacOS/mkv* ]] non_executables+=(${FILE})
    }

    local harden=""
    if [[ -n ${NOTARY_PROFILE} ]] harden="--options=runtime"

    codesign --force --sign ${SIGNATURE_IDENTITY} ${non_executables}
    codesign --force ${harden} --sign ${SIGNATURE_IDENTITY} ${universal_macos}/mkv*(.)
fi

volumename=${APP_NAME}-${universal_release}-${universal_revision}-universal
dmgname=${dmg_dir}/${volumename}.dmg

rm -f ${dmgname}
hdiutil create -srcfolder ${WORK_DIR} -volname ${volumename} \
    -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDZO -imagekey zlib-level=9 \
    ${dmgname}

if [[ -n ${SIGNATURE_IDENTITY} ]] codesign --force -s ${SIGNATURE_IDENTITY} ${dmgname}

if [[ -n $DMG_NO_NOTARIZE ]] return

if [[ -n ${NOTARY_PROFILE} ]]; then
    xcrun notarytool submit ${dmgname} --keychain-profile ${NOTARY_PROFILE} --wait
fi
