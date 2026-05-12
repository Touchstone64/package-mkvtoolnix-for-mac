#! /usr/bin/env zsh

SCRIPT_NAME=${0:t}
SCRIPT_DIR=${0:h}

set -e

if [ $# -ne 1 ]; then
    echo "usage: ${SCRIPT_NAME} <path>"
    echo
    echo "${SCRIPT_NAME} will remove any files matching '*.dmg.sha*.txt' found in <path>."
    exit 1
fi

dmg_dir=${1}

if [[ ! -d ${dmg_dir} ]]; then
    echo "${SCRIPT_NAME}: path not found: ${dmg_dir}"
    exit 2
fi

for candidate in ${dmg_dir}/*.dmg.sha*.txt; do
    type=$(file -b ${candidate})
    if [[ ${type} != "ASCII text" ]]; then
        echo Not removing ${candidate:t} as it is not a text file
    else
        rm ${candidate}
    fi
done