# update_dependencies.rb
#
# Description:
#   This script updates the versions of our development tools and dependencies.
#   It currently supports SwiftLint, SwiftFormat, Tuist, and Cocoapods if specified in a Gemfile.
#
# Usage:
#   This script is run via the `swift setup.swift update-tools`
#   Ensure Gemfile is present if updating Cocoapods version.
#
# Note:
#   Cocoapods are updated via the `setup.swift`` but Swiftlint + SwiftFormat and deliberately updated
#   via their specific scripts to limit the number of requests that need to be done to Github.
#   There is a limit rate to unauthorized requests per IP address of 60/hour.

require 'json'
require 'net/http'
require 'uri'

# Definitions
def get_current_version(tool_name)
  # Fetch current version using mise current
  `mise current #{tool_name}`.strip
end

def get_latest_version(tool_name)
  # Fetch latest version using mise latest
  `mise latest #{tool_name}`.strip
end

def success_message(tool, current_version, latest_version)
  "🟢  Updated #{tool} from #{current_version} to #{latest_version}"
end

def no_update_message(tool, current_version)
  "🟡  No update needed for #{tool}. Current version matches the latest version: #{current_version}"
end

def failure_message(tool, error_message)
  "🔴  Failed to update #{tool}. #{error_message}"
end

def gemfile_contains_cocoapods?(gemfile_content)
  !!gemfile_content.match(/gem 'cocoapods'/)
end

def update_gemfile_with_cocoapods_version(cocoapods_version, gemfile_content)
  updated_content = gemfile_content.gsub(/gem 'cocoapods', '.*'/, "gem 'cocoapods', '#{cocoapods_version}'")
  File.write('Gemfile', updated_content)
end

def update_cocoapods_version(gemfile_content)
  if gemfile_contains_cocoapods?(gemfile_content)
    current_cocoapods_version_match = gemfile_content.match(/gem 'cocoapods', '(.*?)'/)

    if current_cocoapods_version_match
      current_cocoapods_version = current_cocoapods_version_match[1]
      latest_cocoapods_version = `gem info cocoapods --remote | grep '^cocoapods' | awk '{print $2}' | tr -d '()'`.strip

      if latest_cocoapods_version.empty?
        puts failure_message('Cocoapods', 'Unable to fetch latest version.')
      elsif current_cocoapods_version != latest_cocoapods_version
        update_gemfile_with_cocoapods_version(latest_cocoapods_version, gemfile_content)
        puts success_message('Cocoapods', current_cocoapods_version, latest_cocoapods_version)

        # Update Cocoapods by installing the bundle
        system('swift setup.swift install-bundle')
        system('bundle exec pod install')
      else
        puts no_update_message('Cocoapods', current_cocoapods_version)
      end
    else
      puts 'Error parsing current Cocoapods version in Gemfile.'
    end
  else
    puts "Gemfile doesn't contain Cocoapods"
  end
end

def update_mise_self
  puts "Running Mise self-update..."
  system('mise self-update')
end

# Update Mise
update_mise_self

# Tools
tools = ['swiftlint', 'swiftformat', 'tuist']

# Update each of the tools specified above
tools.each do |mise_key|
  begin
    # Fetch current and latest versions using mise commands
    current_version = get_current_version(mise_key)
    latest_version = get_latest_version(mise_key)

    if latest_version.empty?
      puts failure_message(mise_key.capitalize, 'Unable to fetch the latest version using mise latest.')
      next
    end

    if current_version != latest_version
      # Use mise use to set the tool to the latest version
      system("mise use #{mise_key}@#{latest_version}")

      # Success message
      puts success_message(mise_key.capitalize, current_version, latest_version)
    else
      # No update needed message
      puts no_update_message(mise_key.capitalize, current_version)
    end
  rescue StandardError => e
    puts failure_message(mise_key.capitalize, e.message)
  end
end

# Update Cocoapods if found in Gemfile
if File.exist?('Gemfile')
  begin
    gemfile_content = File.read('Gemfile')
    update_cocoapods_version(gemfile_content)
  rescue StandardError => e
    puts failure_message('Cocoapods', e.message)
  end
else
  puts 'Gemfile does not exist.'
end