#!/bin/bash

# Description:
# This script facilitates the running of SwiftLint.
# It checks for the correct version of SwiftLint, and runs SwiftLint.
# The desired version of SwiftLint is fetched directly via mise.

# Usage:
# This script is run as a pre-build phase script.
# In a CI environment, SwiftLint will be run by Danger instead.

# Exit Codes:
# - 0: SwiftLint ran successfully or script exited early in a CI environment.
# - 1: An error occurred, such as SwiftLint not being installed or version mismatch.

if [ $CI ]; then
    echo "No need to run SwiftLint, Danger will run it!"
    exit 0
fi

cd "$(dirname "$0")/.."

# Activate Mise so that Xcode can find it (https://mise.jdx.dev/ide-integration.html#xcode)
eval "$($HOME/.local/bin/mise activate -C $SRCROOT bash --shims)"

if ! mise which swiftlint >/dev/null; then
    echo "error: SwiftLint is not installed. Install by running setup.swift install or setup.swift install-dependencies"
    exit 1
fi

desired_version=$(mise current swiftlint)
current_version=$(mise exec -- swiftlint --version)

if [[ $current_version != $desired_version ]]; then
    echo "error: SwiftLint version mismatch. Expected $desired_version but found $current_version."
    echo "error: Install the correct version by running setup.swift install"
    exit 1
fi

# Run SwiftLint
mise exec -- swiftlint