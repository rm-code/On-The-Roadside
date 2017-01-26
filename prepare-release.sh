#!/bin/bash

# Stop if no version flag is provided.
if ! [[ $1 == "major" || $1 == "minor" || $1 == "patch" ]] ; then
    echo "FAILED: Use major, minor or patch to release a new version."
    exit 1
fi

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

old="$major.$minor.$patch.$build"

# Increment version based on command.
if [ $1 == "major" ] ; then
    major=$((major+1))
    minor=0
    patch=0
elif [[ $1 == "minor" ]]; then
    minor=$((minor+1))
    patch=0
elif [[ $1 == "patch" ]]; then
    patch=$((patch+1))
fi

# Use the git count as build number.
build=$(git rev-list develop --count)

formatted="$major.$minor.$patch.$build"

echo "####################################################"
echo ""
echo "    Preparing release ($old -> $formatted)"
echo ""
echo "####################################################"

# Create a new feature branch via git flow.
git flow release start "$formatted"

# Check if git flow branch was created.
if [ ! $? -eq 0 ]; then
    echo "FAILED to create a release branch! Rolling back changes ..."
    exit 1
fi

# Update README.md
tag="[![Version](https://img.shields.io/badge/Version-$formatted-blue.svg)](https://github.com/rm-code/on-the-roadside/releases/latest)";
sed -n "1, 2p"  ./README.md >> tmp_README.md
echo $tag                   >> tmp_README.md
sed -n "4, 28p" ./README.md >> tmp_README.md
mv tmp_README.md README.md

# Add new section to changelog.
echo "# Version $formatted - $(date +"%Y-%m-%d")" >> tmp_changelog
cat CHANGELOG.md >> tmp_changelog
mv tmp_changelog CHANGELOG.md

# Update version.lua.
echo "local version = {"    >> tmp_version
echo "    major = $major,"  >> tmp_version
echo "    minor = $minor,"  >> tmp_version
echo "    patch = $patch,"  >> tmp_version
echo "    build = $build,"  >> tmp_version
echo "}"                    >> tmp_version
echo ""                     >> tmp_version
echo 'return string.format( "%d.%d.%d.%d", version.major, version.minor, version.patch, version.build );' >> tmp_version
mv tmp_version version.lua

# Commit the changes.
git commit -a -m "Prepare version $formatted"

echo "####################################################"
echo ""
echo "           Update the Changelog now!"
echo ""
echo "####################################################"
