#! /usr/bin/env zsh

DMG_DIRECTORY=~/tmp/compile

function create_checksum_file_for_target {
    local target=$1
    local algorithm=$2
    local filename=${target:t}
    local outputfile=${target}.sha${algorithm}.txt
    local checksum=$(shasum -a ${algorithm} ${target} | cut -d ' ' -f 1)

    echo "${checksum}  ${filename}" > ${outputfile}
}

for dmg in ${DMG_DIRECTORY}/*.dmg; do
    create_checksum_file_for_target ${dmg} 1
    create_checksum_file_for_target ${dmg} 256
    create_checksum_file_for_target ${dmg} 512
done