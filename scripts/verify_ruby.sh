#!/bin/bash

# Description:
# This script ensures, the recommended Ruby version specified in a .ruby-version file, is installed and active for this repository.
# If the required version is not found, the script attempts to install it using the detected Ruby version manager (rbenv, rvm, or chruby).

recommended_ruby_version=$(cat .ruby-version)
# Attempt to get the current Ruby version, capturing any error output
current_ruby_version=$(ruby -e 'puts RUBY_VERSION' 2>&1)

# Function to check which Ruby version manager is in use
detect_ruby_manager() {
  if command -v rbenv >/dev/null 2>&1; then
    echo "rbenv"
  elif command -v rvm >/dev/null 2>&1; then
    echo "rvm"
  elif command -v chruby >/dev/null 2>&1; then
    echo "chruby"
  else
    echo "none"
  fi
}

install_ruby_version() {
  local version=$1
  local manager=$2

  case $manager in
    rbenv)
      echo "Attempting to install Ruby $version using rbenv..."
      brew update && brew upgrade rbenv ruby-build # make sure that we have latest ruby-build
      rbenv install "$version" && rbenv local "$version"
      ;;
    rvm)
      echo "Attempting to install Ruby $version using rvm..."
      rvm install "$version" && rvm use "$version"
      ;;
    chruby)
      echo "Attempting to install Ruby $version using ruby-install..."
      ruby-install ruby-"$version" && chruby ruby-"$version"
      ;;
    *)
      echo "Unable to install Ruby $version. Unsupported Ruby version manager."
      return 1
      ;;
  esac
}

# Function to output a warning message and instructions based on the Ruby manager
output_warning() {
  local recommended_ruby_version=$1
  local ruby_manager=$2

  echo "⚠️  Recommended Ruby version $recommended_ruby_version is not installed."

  # ANSI escape code to start bold and underline text
  local bold_underline="\033[1;4m"

  # ANSI escape code to reset text formatting
  local reset="\033[0m"

  case $ruby_manager in
    rbenv)
      echo -e "Please install it using rbenv with the following command:"
      echo -e "${bold_underline}rbenv install $recommended_ruby_version${reset}"
      ;;
    rvm)
      echo -e "Please install it using rvm with the following command:"
      echo -e "${bold_underline}rvm install $recommended_ruby_version${reset}"
      ;;
    chruby)
      echo -e "Please install it using ruby-install with the following command:"
      echo -e "${bold_underline}ruby-install ruby-$recommended_ruby_version${reset}"
      ;;
    *)
      echo "Please install it using your Ruby version manager."
      ;;
  esac
}

# If the current Ruby version matches the recommended version, we're done
if [[ "$current_ruby_version" == "$recommended_ruby_version" ]]; then
  echo "🟢  Found recommended Ruby version: $recommended_ruby_version"
  exit 0
fi

ruby_manager=$(detect_ruby_manager)

# Attempt to install the recommended Ruby version
install_ruby_version "$recommended_ruby_version" "$ruby_manager"
install_result=$?

# Check the Ruby version again after attempting to install
current_ruby_version=$(ruby -e 'puts RUBY_VERSION' 2>&1)

if [[ "$current_ruby_version" == "$recommended_ruby_version" ]]; then
  echo "🟢  Successfully installed and switched to recommended Ruby version: $recommended_ruby_version"
  exit 0
elif [[ $install_result -eq 0 ]]; then
  echo "⚠️  Installed Ruby $recommended_ruby_version, but failed to switch to it. Please check your Ruby version manager."
  exit 1
else
  output_warning "$recommended_ruby_version" "$ruby_manager"
  exit 1
fi