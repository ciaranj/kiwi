
require 'rubygems'
require 'sinatra'
require 'yaml'

SEEDS = File.dirname(__FILE__) + '/seeds'

helpers do
  def seed_info
    @info ||= YAML.load_file SEEDS + '/seeds.yml'
  end
  
  def seed name
    seed_info[name]
  end
  
  def transfer_seed name, version
    path = SEEDS + "/#{name}/#{version}.seed"
    File.exists?(path) || halt(404)
    content_type :tar
    send_file path
  end
end

##
# Search seeds, all are listed unless filtered by:
#
#  - :name
#

get '/search' do
  seed_info.map do |name, info|
    next if params[:name] && !name.include?(params[:name])
    '%15s : (%s)' % [name, info.keys.join(', ')]
  end.compact.join("\n") + "\n"
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