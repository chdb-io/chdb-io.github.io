#!/bin/bash

# Check for necessary tools
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but it's not installed. Aborting."; exit 1; }
command -v tar >/dev/null 2>&1 || { echo >&2 "tar is required but it's not installed. Aborting."; exit 1; }

# Get the newest release version
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/chdb-io/chdb/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Select the correct package based on OS and architecture
case "$(uname -s)" in
    Linux)
        if [[ $(uname -m) == "aarch64" ]]; then
            PLATFORM="linux-aarch64-libchdb.tar.gz"
        else
            PLATFORM="linux-x86_64-libchdb.tar.gz"
        fi
        ;;
    Darwin)
        if [[ $(uname -m) == "arm64" ]]; then
            PLATFORM="macos-arm64-libchdb.tar.gz"
        else
            PLATFORM="macos-x86_64-libchdb.tar.gz"
        fi
        ;;
    *)
        echo "Unsupported platform"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/chdb-io/chdb/releases/download/$LATEST_RELEASE/$PLATFORM"

echo "Downloading $PLATFORM from $DOWNLOAD_URL"

# Download the file
curl -L -o libchdb.tar.gz $DOWNLOAD_URL

# Optional: Verify download integrity here, if checksums are provided

# Untar the file
tar -xzf libchdb.tar.gz

# If current uid is 0, SUDO is not required
SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

# Install the library and header file
${SUDO} /bin/cp libchdb.so /usr/local/lib/
${SUDO} /bin/cp chdb.h /usr/local/include/

# Set execute permission for libchdb.so
${SUDO} chmod +x /usr/local/lib/libchdb.so

# Update library cache (Linux specific)
if [[ "$(uname -s)" == "Linux" ]]; then
    ${SUDO} ldconfig
fi

# Clean up
rm -f libchdb.tar.gz libchdb.so chdb.h

echo "Installation completed successfully."
echo "If any error occurred, please report it to:"
echo "  https://github.com/chdb-io/chdb/issues/new/choose"
