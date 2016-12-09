#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

bosh_lite_target = ENV['BOSH_TARGET']
system("bosh target #{bosh_lite_target}")

# Use a minimal deployment manifest designed just for compiling releases
manifest_template = File.join("buildpacks-ci", "tasks", "generate-bosh-lite-edge-compiled-releases", "bosh-compile-manifest-template.yml")
manifest_contents = File.read(manifest_template)
# Use correct BOSH Lite Director UUID
director_uuid = `bosh status --uuid`.strip
manifest_contents.gsub!("REPLACE_WITH_DIRECTOR_UUID", director_uuid)
File.write("compile-manifest.yml", manifest_contents)
system("bosh deployment compile-manifest.yml")
puts "Deployment set to minimal compilation manifest"

# BOSH Upload stemcell
puts "Uploading BOSH stemcell..."
raise "Stemcell upload failed" unless system("bosh upload stemcell bosh-stemcell/stemcell.tgz")
stemcell_version_file = "bosh-stemcell/version"
stemcell_version = File.read(stemcell_version_file).strip

# BOSH Upload releases
puts "Uploading BOSH releases..."
bosh_releases = %w(cf diego garden-runc cflinuxfs2-rootfs)
bosh_releases.each do |release_name|
  raise "Release upload failed" unless system("bosh upload release #{release_name}-bosh-release/release.tgz")
end

# Update BOSH Cloud Config
# Networks + compilation have to be defined either in BOSH manifest or cloud config
cloud_config_file = File.join("buildpacks-ci", "tasks", "generate-bosh-lite-edge-compiled-releases", "cloud.yml")
raise "BOSH updating of cloud config failed" unless system("bosh update cloud-config #{cloud_config_file}")

raise "BOSH deploy failed" unless system("echo 'yes' | bosh deploy")

# BOSH export releases
puts "Compiling and exporting compiled BOSH releases..."
bosh_releases = %w(cf diego garden-runc cflinuxfs2-rootfs)
bosh_releases.each do |release_name|
  release_version_file = "#{release_name}-bosh-release/version"
  release_version = File.read(release_version_file).strip
  puts "BOSH EXPORT COMMAND"
  puts "bosh export release #{release_name}-bosh-release/#{release_version} ubuntu-trusty/#{stemcell_version}"
  raise "Export failed" unless system("bosh export release #{release_name}/#{release_version} ubuntu-trusty/#{stemcell_version}")
  # Generates file that looks like release-cf-248-on-ubuntu-trusty-stemcell-3312.5.tgz
  generated_compiled_release_tar = "release-#{release_name}-#{release_version}-on-ubuntu-trusty-stemcell-#{stemcell_version}.tgz"
  # Move and rename tarballs
  FileUtils.mv(generated_compiled_release_tar, "compiled-releases/#{release_name}.tgz")
end
