#!/usr/bin/env ruby
# encoding: utf-8

buildpacks_ci_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

require "#{buildpacks_ci_dir}/lib/buildpack-cve-tags"
require "#{buildpacks_ci_dir}/lib/buildpack-cve-history"
require "#{buildpacks_ci_dir}/lib/notifiers/buildpack-system-cve-slack-notifier"
require "#{buildpacks_ci_dir}/lib/notifiers/buildpack-system-cve-email-preparer-and-github-issue-notifier"

def notify!(language, new_cves, notifiers)
  notifiers.each { |n| n.notify! new_cves, { :category => "buildpack-#{language}", :label => language } }
end

buildpack_cves_dir = File.expand_path(File.join(buildpacks_ci_dir, '..', 'output-new-buildpack-cves', 'new-buildpack-cve-notifications'))

languages = ['ruby']
languages.each do |language|
  past_cves = BuildpackCVEHistory.read_yaml_cves(buildpack_cves_dir, "#{language}.yml")
  rss_cves = BuildpackCVETags.run(language)
  new_cves = rss_cves - past_cves

  BuildpackCVEHistory.write_yaml_cves(rss_cves, buildpack_cves_dir, "#{language}.yml") unless new_cves.empty?

  notify!(language, new_cves, [BuildpackSystemCVEEmailPreparerAndGithubIssueNotifier, BuildpackSystemCVESlackNotifier])
end
