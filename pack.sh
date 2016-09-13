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

# Move to releases folder and cd to releases.
mv -i -v OTR_$formatted.love ../releases
cd ../releases || exit

# Unzip the LÖVE binaries.
unzip LOVE_bin.zip -d LOVE_0101

# Create the executable.
cp ./OTR_$formatted.love ./LOVE_0101
cd LOVE_0101 || exit
cat love.exe OTR_$formatted.love > OTR_$formatted.exe
rm love.exe
rm OTR_$formatted.love

# Zip all files.
zip -r OTR_$formatted.zip ./ -x *.git* -x *.DS_Store*
mv -i -v OTR_$formatted.zip ../

# Remove the folder.
cd ..
rm -r LOVE_0101
