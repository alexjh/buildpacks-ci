#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'yaml'

buildpacks_ci_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require "#{buildpacks_ci_dir}/lib/cf-release-common"

replacement_function = <<-FUNCTION
running_in_container() {
  true
}
FUNCTION

Dir.chdir 'diego-release' do
  files_to_edit = Dir["**/*.sh"].select do |file|
    File.read(file).include? 'running_in_container()'
  end

  files_to_edit.each do |file|
    contents=File.read(file)

    contents.gsub!(/running_in_container\(\)\s+{.*}/m, replacement_function )
    File.write(file, contents)
    puts "Replaced running_in_container() in #{file}"
  end

  system(%(bosh --parallel 10 sync blobs && bosh create release --force --with-tarball --name diego)) || raise('cannot create diego-release')
end

system('rsync -a diego-release/ diego-release-artifacts') || raise('cannot rsync directories')
