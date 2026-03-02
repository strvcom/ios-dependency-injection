#!/bin/bash

desired_bundler_version=$(cat .bundler-version)
installed_bundler_version=$(gem list bundler | grep -w $desired_bundler_version)

if [ -z "$installed_bundler_version" ]; then
  echo "Bundler version $desired_bundler_version is not installed. Installing now..."
  gem install bundler -v $desired_bundler_version
else
  echo "Found correct Bundler version: $desired_bundler_version"
fi