
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
# Transfer the latest version of the requested seed _name_.

get '/:name' do 
  versions = seed(params[:name]) || halt(404)
  transfer_seed params[:name], versions.keys.first
end

##
# Transfer _version_ of the requested seed _name_.

get '/:name/:version' do
  transfer_seed params[:name], params[:version]
end

run Sinatra::Application