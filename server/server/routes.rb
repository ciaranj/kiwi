
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
