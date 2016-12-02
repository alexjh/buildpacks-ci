#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

def all_pipelines
  %w(
    stacks
    stacks-nc
    cf-release
    binary-builder
    brats
    buildpack-verification
    buildpacks-ci
    concourse2tracker-resource
    dockerfile
    gems-and-extensions
    notifications-nc
    notifications
    php-notifications
    sample-apps
    edge-1-gcp
    edge-2-gcp
    lts-1-gcp
    lts-2-gcp
    lts-1
    lts-2
    edge-1
    edge-2
    unclaim-bosh-lites
    binary-buildpack
    dotnet-core-buildpack
    go-buildpack
    multi-buildpack
    nodejs-buildpack
    php-buildpack
    python-buildpack
    ruby-buildpack
    staticfile-buildpack
  )
end

def add_prefix_for_all_jobs(prefix, jobs_array)
  jobs_array.each_with_index do |job, index|
    job['name'] = "#{prefix}-#{job['name']}"
    job['plan'] = recursive_edit_for_passed(prefix, job['plan'])
    job['plan'] = recursive_edit_for_resources(prefix, job['plan'])
    jobs_array[index] = job
  end
  jobs_array
end

def add_prefix_for_all_resources(prefix, resources_array)
  resources_array.each_with_index do |resource, index|
    resource['name'] = "#{prefix}-#{resource['name']}"
    resources_array[index] = resource
  end
  resources_array
end

def recursive_edit_for_passed(prefix, item)
  if item.class == Hash
    item.each do |key, value|
      if key == 'passed' && value.class == Array
        prefixed_passed = value.map do |job|
          "#{prefix}-#{job}"
        end
        item[key] = prefixed_passed
      else
        item[key] = recursive_edit_for_passed(prefix, value)
      end
    end
  elsif item.class == Array
    item.each_with_index do |element, index|
      item[index] = recursive_edit_for_passed(prefix, element)
    end
  end
  return item
end

def recursive_edit_for_resources(prefix, item)
  if item.class == Hash
    item.each do |key, value|
      key_is_get = (key == 'get' && value.class == String && !item.has_key?('resource'))
      key_is_resource = (key == 'resource' && value.class == String)
      key_is_put = (key == 'put' && value.class == String)
      if key_is_get || key_is_resource || key_is_put
        prefixed_resource = "#{prefix}-#{value}"
        item[key] = prefixed_resource
      else
        item[key] = recursive_edit_for_resources(prefix, value)
      end
    end
  elsif item.class == Array
    item.each_with_index do |element, index|
      item[index] = recursive_edit_for_resources(prefix, element)
    end
  end
  return item
end

def generate_aggregate_pipe_yaml
  aggregate_pipelines_yaml = {}
  jobs_yaml = []
  resource_types_yaml = []
  resources_yaml = []

  get_pipeline_command = "fly -t buildpacks get-pipeline -p "

  all_pipelines.each do |pipeline|
    puts "Getting #{pipeline} pipeline"
    pipeline_contents = `#{get_pipeline_command} #{pipeline}`
    pipeline_yaml = YAML.load(pipeline_contents)

    resources_with_prefixes = add_prefix_for_all_resources(pipeline, pipeline_yaml['resources'])
    jobs_with_prefixes = add_prefix_for_all_jobs(pipeline, pipeline_yaml['jobs'])

    resource_types_yaml.push(*pipeline_yaml['resource_types']) if pipeline_yaml.has_key? 'resource_types'
    resources_yaml.push(*resources_with_prefixes) if pipeline_yaml.has_key? 'resources'
    jobs_yaml.push(*jobs_with_prefixes) if pipeline_yaml.has_key? 'jobs'
  end

  aggregate_pipelines_yaml['resource_types'] = resource_types_yaml.uniq
  aggregate_pipelines_yaml['resources'] = resources_yaml.uniq
  aggregate_pipelines_yaml['jobs'] = jobs_yaml.uniq
  aggregate_pipelines_yaml
end

def run!
  aggregate_pipelines_yaml = generate_aggregate_pipe_yaml

  begin
    File.write('aggregate-pipelines.yml', aggregate_pipelines_yaml.to_yaml)
    puts "Creating aggregate pipeline"
    `yes | fly -t buildpacks set-pipeline --pipeline=aggregate-pipelines --config=aggregate-pipelines.yml`
    puts
    puts "'Measuring programming progress by number of pipelines is like measuring aircraft building progress by weight.' - James Wen, adapted from Bill Gates"
  ensure
    FileUtils.rm_rf('aggregate-pipelines.yml')
  end
end

run!
