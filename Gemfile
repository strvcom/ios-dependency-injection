# By Jan Schwarz 03/24/2021
# STRV s.r.o. 2021
# STRV

source 'https://rubygems.org'
gem 'bundler', '~> 2.6.3'
gem 'danger', '~> 8.2.0'
gem 'fastlane', '~> 2.217.0'  # Novější verze podporující Ruby 3.x

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)