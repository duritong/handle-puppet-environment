#! /usr/bin/ruby
#
# Sample External Node script for Puppet Dashboard
#
# == puppet.conf Configuration
#
#  [main]
#  external_nodes = /path/to/external_node
#  node_terminus = exec

require 'yaml'
require 'uri'
require 'net/http'

def get_node_previous_environment(nodefile,fqdn)
  # Inspect the previously stored node file
  return nil unless File.exists?(nodefile)
  
  YAML.load_file(nodefile)['parameters']['environment']
end

def handle_env(content)
  parsed_content = YAML.load(content)
  nodefile = File.join('/var/lib/puppet/yaml/node_enc', "#{NODE}.yaml")
  old_env = get_node_previous_environment(nodefile,NODE)
  
  if !old_env.nil? && parsed_content['parameters']['environment'] != old_env
    parsed_content['classes'] = [ 'puppet::enforce_environment' ]
    content = YAML.dump(parsed_content)
  end
  File.open(nodefile,'w'){|f| f << content }
  content
end

DASHBOARD_URL = "http://localhost:3000"

# These settings are only used when connecting to dashboard over https (SSL)
CERT_PATH = "/etc/puppet/ssl/certs/puppet.pem"
PKEY_PATH = "/etc/puppet/ssl/private_keys/puppet.pem"
CA_PATH   = "/etc/puppet/ssl/certs/ca.pem"

cert_path = ENV['PUPPET_CERT_PATH'] || CERT_PATH
pkey_path = ENV['PUPPET_PKEY_PATH'] || PKEY_PATH
ca_path   = ENV['PUPPET_CA_PATH']   || CA_PATH

NODE = ARGV.first

url = ENV['PUPPET_DASHBOARD_URL'] || DASHBOARD_URL
uri = URI.parse("#{url}/nodes/#{NODE}")
require 'net/https' if uri.scheme == 'https'

request = Net::HTTP::Get.new(uri.path, initheader = {'Accept' => 'text/yaml'})
request.basic_auth uri.user, uri.password if uri.user
http = Net::HTTP.new(uri.host, uri.port)
if uri.scheme == 'https'
  cert = File.read(cert_path)
  pkey = File.read(pkey_path)
  http.use_ssl = true
  http.cert = OpenSSL::X509::Certificate.new(cert)
  http.key = OpenSSL::PKey::RSA.new(pkey)
  http.ca_file = ca_path
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
end
result = http.start {|http| http.request(request)}

case result
when Net::HTTPSuccess; puts handle_env(result.body); exit 0
else; STDERR.puts "Error: #{result.code} #{result.message.strip}\n#{result.body}"; exit 1
end

