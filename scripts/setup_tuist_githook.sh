#!/bin/bash

# Script for generating project files from the Tuist definition files
script="
# Tuist
if [ -f \"App/Project.swift\" ]; then
	tuist generate --no-open
fi"

# Destination file where the script should be set
hookFile=".githooks/post-checkout"

if [ ! -f "$hookFile" ]; then 
	# post-checkout git hook file doesn't exist - create file, add header, and script
  	echo "#!/bin/bash" > "$hookFile"
  	echo "$script" >> "$hookFile"
elif ! grep -q "Tuist" "$hookFile"; then
	# File exists but the Tuist section is missing - add just the script
	echo "$script" >> "$hookFile"
fi

# Hooks needs to be executable
chmod +x .githooks/post-checkout