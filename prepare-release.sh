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

echo "Old Version: $major.$minor.$patch.$build"

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

echo "New Version: $formatted"

echo "Creating a release branch using git flow ..."

# Create a new feature branch via git flow.
git flow release start "$formatted"

# Check if git flow branch was created.
if [ ! $? -eq 0 ]; then
    echo "FAILED to create a release branch! Rolling back changes ..."
    exit 1
fi

# Add new section to changelog.
echo "## Other Changes" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
echo "## Fixes" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
echo "## Removals" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
echo "## Additions" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
echo "# Version $formatted - $(date +"%Y-%m-%d")" | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md

# Replace in version.lua.
sed -e "s/.*major =.*/    major = $major,/" version.lua | tee version.lua
sed -e "s/.*minor =.*/    minor = $minor,/" version.lua | tee version.lua
sed -e "s/.*patch =.*/    patch = $patch,/" version.lua | tee version.lua
sed -e "s/.*build =.*/    build = $build,/" version.lua | tee version.lua

# Commit the changes.
git commit -a -m "Prepare version $formatted"
