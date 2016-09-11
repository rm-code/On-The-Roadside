#!/bin/bash

# Get the version numbers from the lua file and store them in an array.
i=0
while read line ; do
    no=${line//[!0-9]/}
    if [ ! -z "$no" ]; then
        version[$i]=${line//[!0-9]/}
        i=$((i+1))
    fi
done < version.lua

# Assign to variables.
major=${version[0]}
minor=${version[1]}
patch=${version[2]}
build=${version[3]}

formatted="$major$minor$patch-$build"

# Zip files. Exclude git folder and DS_Store files.
zip -r OTR_$formatted.love ./ -x *.git* -x *.DS_Store*

# Move to releases folder.
mv -i -v OTR_$formatted.love ../releases
