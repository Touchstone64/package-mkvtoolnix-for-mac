#! /usr/bin/env zsh

DMG_DIRECTORY=~/tmp/compile

for candidate in ${DMG_DIRECTORY}/*.dmg.sha*.txt; do
    type=$(file -b ${candidate})
    if [[ ${type} != "ASCII text" ]]; then
        echo Not removing ${candidate:t} as it is not a text file
    else
        rm ${candidate}
    fi
done