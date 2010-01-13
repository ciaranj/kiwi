
require 'rubygems'
require 'sinatra'
require 'yaml'

SEEDS = File.dirname(__FILE__) + '/seeds'

helpers do
  def seed name
    (@seeds ||= YAML.load_file SEEDS + '/seeds.yml')[name]
  end
  
  def transfer_seed name, version
    path = SEEDS + "/#{name}/#{version}.seed"
    File.exists?(path) || halt(404)
    content_type :tar
    send_file path
  end
end

##
# Transfer the requested seed when present.

get '/*' do |name|
  versions = seed(name) || halt(404)
  transfer_seed name, versions.keys.first
end

run Sinatra::Application