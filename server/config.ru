
require 'rubygems'
require 'sinatra'
require 'yaml'

SEEDS = File.dirname(__FILE__) + '/seeds'

helpers do
  
  ##
  # Return array of seed paths.
  
  def seed_paths
    Dir[SEEDS + '/*']
  end
  
  ##
  # Return array of versions for the given seed _name_.
  
  def seed_versions name
    Dir[SEEDS + "/#{name}/*.yml"].map do |version| 
      File.basename(version).sub('.yml', '')
    end
  end
  
  ##
  # Return array of seed names.
  
  def seed_names
    seed_paths.map { |path| File.basename path }
  end
  
  ##
  # Read yaml file for seed _name_ and _version_.
  
  def seed name, version
    YAML.load_file SEEDS + "/#{name}/#{version}.yml"
  end
  
  ##
  # Transfer seed _name_ and _version_ if it exists.
  
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
  seed_names.map do |name|
    next if params[:name] && !name.include?(params[:name])
    '%15s : %s' % [name, seed_versions(name).join(' ')]
  end.compact.join("\n") + "\n"
end

##
# Transfer the latest version of the requested seed _name_.

get '/:name' do 
  versions = seed(params[:name]) || halt(404)
  version = versions.keys.first
  transfer_seed params[:name], version
end

##
# Output latest version for seed _name_.

get '/:name/latest' do
  versions = seed_versions(params[:name]) || halt(404)
  versions.first
end

##
# Transfer _version_ of the requested seed _name_.

get '/:name/:version' do
  transfer_seed params[:name], params[:version]
end

run Sinatra::Application