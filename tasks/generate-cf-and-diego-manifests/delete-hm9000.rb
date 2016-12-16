#!/usr/bin/env ruby

require 'yaml'

cf_release_dir = ARGV[0]
cf_manifest_file = ARGV[1]

Dir.chdir(cf_release_dir) do
  cf_manifest = YAML.load_file(cf_manifest_file)

  cf_manifest['jobs'].delete_if { |j| j['name'].include? 'hm9000'}

  File.write(cf_manifest_file, cf_manifest.to_yaml)
end
