local version = {
    major = 0,
    minor = 0,
    patch = 0,
    build = 0,
}

return string.format( "%d.%d.%d-(%d)", version.major, version.minor, version.patch, version.build );
