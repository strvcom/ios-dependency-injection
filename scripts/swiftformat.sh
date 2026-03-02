#!/bin/bash

# Description:
# This script facilitates the running of SwiftFormat.
# It checks for the correct version of SwiftFormat, and runs SwiftFormat on git staged files using 'git-format-staged' binary.
# The desired version of SwiftFormat is specified in a '.swiftformat-version' file located in the project root directory.

# Usage:
# This script is executed during pre-commit git hook in order to prevent the loss of Xcode's undo functionality

# Exit Codes:
# - 0: SwiftFormat ran successfully or script exited early in a CI environment.
# - 1: An error occurred, such as SwiftFormat not being installed or version mismatch.

if [ $CI ]; then
    echo "No need to run SwiftFormat on CI"
    exit 0
fi

cd "$(dirname "$0")/.."

eval "$($HOME/.local/bin/mise activate -C $SRCROOT bash --shims)"

swiftformat_bin=$(mise which swiftformat)

if ! mise which swiftformat >/dev/null; then
    echo "error: SwiftFormat is not installed. Install by running setup.swift install or setup.swift install-dependencies"
    exit 1
fi

desired_version=$(mise current swiftformat)
current_version=$(mise exec -- swiftformat --version)

if [[ $current_version != $desired_version ]]; then
    echo "error: SwiftFormat version mismatch. Expected $desired_version but found $current_version."
    echo "error: Install the correct version by running setup.swift install"
    exit 1
fi

# Run SwiftFormat on git-staged files
cd "$(git rev-parse --show-toplevel)"

./scripts/git-format-staged --formatter "$swiftformat_bin stdin --stdinpath '{}'" "*.swift"