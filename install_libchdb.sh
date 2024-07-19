#!/bin/bash

set -e

# Check for necessary tools
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but it's not installed. Aborting."; exit 1; }
command -v tar >/dev/null 2>&1 || { echo >&2 "tar is required but it's not installed. Aborting."; exit 1; }

# Get the newest release version
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/chdb-io/chdb/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ $? -ne 0 ]]; then
    echo "Error fetching the latest release version, trying the fallback URL."
    LATEST_RELEASE="latest"  # Using 'latest' as the fallback release version
fi

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
FALLBACK_URL="https://github.com/chdb-io/chdb/releases/latest/download/$PLATFORM"

echo "Downloading $PLATFORM from $DOWNLOAD_URL"

# Download the file
if ! curl -L -o libchdb.tar.gz $DOWNLOAD_URL; then
    echo "Failed to download the package, attempting to download from fallback URL."
    if ! curl -L -o libchdb.tar.gz $FALLBACK_URL; then
        echo "Failed to download the package from both primary and fallback URLs. Aborting."
        exit 1
    fi
fi

# Optional: Verify download integrity here, if checksums are provided

# Untar the file
if ! tar -xzf libchdb.tar.gz; then
    echo "Failed to extract the package. Aborting."
    exit 1
fi

# If current uid is not 0, check if sudo is available and request the user to input the password
if [[ $EUID -ne 0 ]]; then
    command -v sudo >/dev/null 2>&1 || { echo >&2 "This script requires sudo privileges but sudo is not installed. Aborting."; exit 1; }
    echo "Installation requires administrative access. You will be prompted for your password."
fi

# Define color messages if terminal supports them
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'  # No Color
    REDECHO() { echo -e "${RED}$@${NC}"; }
    GREENECHO() { echo -e "${GREEN}$@${NC}"; }
    ENDECHO() { echo -ne "${NC}"; }
else
    REDECHO() { echo "$@"; }
    GREENECHO() { echo "$@"; }
    ENDECHO() { :; }
fi

# Use sudo if not running as root
SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
    GREENECHO "\nYou will be asked for your sudo password to install:"
    echo "    libchdb.so to /usr/local/lib/"
    echo "    chdb.h to /usr/local/include/"
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

GREENECHO "Installation completed successfully." ; ENDECHO
REDECHO "If any error occurred, please report it to:" ; ENDECHO
REDECHO "    https://github.com/chdb-io/chdb/issues/new/choose" ; ENDECHO
