#! /usr/bin/env zsh

SCRIPT_NAME=${0:t}
SCRIPT_DIR=${0:h}

set -e

function create_checksum_file_for_target {
    local target=$1
    local algorithm=$2
    local filename=${target:t}
    local outputfile=${target}.sha${algorithm}.txt
    local checksum=$(shasum -a ${algorithm} ${target} | cut -d ' ' -f 1)

    echo "${checksum}  ${filename}" > ${outputfile}
}

if [ $# -ne 1 ]; then
    echo "usage: ${SCRIPT_NAME} <path>"
    echo
    echo "${SCRIPT_NAME} will create or replace SHA checksum files for any .dmg packages"
    echo "found in <path>, using algorithms 1, 256 and 512, in the form <dmg-name>.sha<algorithm>.txt"
    exit 1
fi

dmg_dir=${1}

if [[ ! -d ${dmg_dir} ]]; then
    echo "${SCRIPT_NAME}: path not found: ${dmg_dir}"
    exit 2
fi

for dmg in ${dmg_dir}/*.dmg; do
    create_checksum_file_for_target ${dmg} 1
    create_checksum_file_for_target ${dmg} 256
    create_checksum_file_for_target ${dmg} 512
done