#!/usr/bin/env ruby

require 'yaml'

def create_credentials_file(api_key)
  credentials_yaml = {rubygems_api_key: api_key}.to_yaml
  File.write('~/.gem/credentials', credentials_yaml)
end

api_key = ENV['RUBYGEMS_ORG_API_KEY']
gem_name = ENV['GEM_NAME']

create_credentials_file(api_key)

raise "Building .gem file failed" unless system("gem build #{gem_name}.gemspec")

gem_package = Dir['buildpack-packager-*.gem'].first

raise "Pushing to rubygems.org failed" unless system("gem push #{gem_package}")
