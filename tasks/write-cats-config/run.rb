#!/usr/bin/env ruby

require 'json'


admin_user = ENV['CI_CF_USERNAME']
admin_password = ENV['CI_CF_PASSWORD']
apps_domain = ENV['APPS_DOMAIN']
diego_docker_on = ENV['DIEGO_DOCKER_ON']

cats_config = {
  "api" => "api.#{apps_domain}",
  "apps_domain" => apps_domain,
  "skip_ssl_validation" => true,
  "verbose" => false,
  "include_sso" => false,
  "include_security_groups" => true,
  "include_internet_dependent" => true,
  "include_services" => true,
  "include_v3" => false,
  "include_routing" => false,
  "backend" => "diego",
  "use_http" => true,
  "enable_color" => true,
  "include_ssh" => true,
  "use_existing_user" => false,
  "keep_user_at_suite_end" => false
}

if diego_docker_on == 'true'
  exit 1 unless system "cf api api.#{apps_domain} --skip-ssl-validation"
  exit 1 unless system "echo \"\" | cf login -u #{admin_user} -p #{admin_password}"
  exit 1 unless system "cf enable-feature-flag diego_docker"
  cats_config['include_docker'] = true
end

puts "Using CATS config: #{cats_config.to_json}"

cats_config["admin_user"] = admin_user
cats_config["admin_password"] = admin_password

File.write('integration-config/integration_config.json')
