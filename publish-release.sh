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

# Zip files.
echo "Packing .love file for $major.$minor.$patch.$build"
zip -r -q OTR_$formatted.love ./ -x .\* -x \*.sh -x tests/\* -x README.md -x config.ld

# Move to releases folder and cd to releases.
mkdir ../releases/OTR_$formatted
mv -i -v OTR_$formatted.love ../releases/OTR_$formatted
cd ../releases/OTR_$formatted || exit

## CREATE WINDOWS EXECUTABLE
# Unzip the LÖVE binaries.
unzip -q ../LOVE_bin.zip -d LOVE_WIN

# Create the executable.
echo "Creating .exe"
cp ./OTR_$formatted.love ./LOVE_WIN
cd LOVE_WIN || exit
cat love.exe OTR_$formatted.love > OTR_$formatted.exe

rm -rf __MACOSX
rm lovec.exe
rm love.exe
rm OTR_$formatted.love
cd ..

# Zip all files.
echo "Zipping .exe and binary files"
zip -r -q OTR_$formatted-WIN.zip LOVE_WIN/ -x *.git* -x *.DS_Store*

# Remove the folder.
rm -r LOVE_WIN


## CREATE MAC OS APPLICATION
echo "Creating Mac OS Application"
unzip -q ../LOVE_bin_OSX.zip -d LOVE_OSX

# Rename Application
cd LOVE_OSX || exit
mv love.app OTR_$formatted.app

# Move .love file into the .app
cp ../OTR_$formatted.love OTR_$formatted.app/Contents/Resources

# Copy modifed plist
cp ../../Info.plist OTR_$formatted.app/Contents/

# There probably is a wayyy better way to do this ...
echo "<key>CFBundleShortVersionString</key>" >> OTR_$formatted.app/Contents/Info.plist
echo "<string>$major.$minor.$patch.$build</string>" >> OTR_$formatted.app/Contents/Info.plist
echo "</dict>" >> OTR_$formatted.app/Contents/Info.plist
echo "</plist>" >> OTR_$formatted.app/Contents/Info.plist

# Move to the parent folder
mv -i -v OTR_$formatted.app ../OTR_$formatted-OSX.app

# Zip the .app file.
cd ..
zip -r OTR_$formatted-OSX.zip OTR_$formatted-OSX.app

# Remove the temporary folder and the .app file.
rm -r LOVE_OSX OTR_$formatted-OSX.app


## ZIP THE LOVE FILE
# Fix for https://github.com/itchio/butler/issues/58#issuecomment-299619964
zip OTR_$formatted-LOVE.zip OTR_$formatted.love

# Remove original love file.
rm OTR_$formatted.love

# Publish to itch.io
echo "Publishing to itch.io"
butler push OTR_$formatted-WIN.zip rmcode/on-the-roadside:win --userversion $major.$minor.$patch.$build
butler push OTR_$formatted-OSX.zip rmcode/on-the-roadside:osx --userversion $major.$minor.$patch.$build
butler push OTR_$formatted-LOVE.zip rmcode/on-the-roadside:win-osx-linux --userversion $major.$minor.$patch.$build
