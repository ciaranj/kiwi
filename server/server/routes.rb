
##
# Search seeds, all are listed unless filtered by:
#
#  - :name
#

get '/search' do
  Kiwi::Seed.names.map do |name|
    next if params[:name] && !name.include?(params[:name])
    '%15s : %s' % [name, Kiwi::Seed.new(name).versions.join(' ')]
  end.compact.join("\n") + "\n"
end

##
# Output latest version for seed _name_.

get '/:name/latest' do
  Kiwi::Seed.new(params[:name]).versions.first
end

##
# Transfer _version_ of the requested seed _name_.

get '/:name/:version' do
  seed = Kiwi::Seed.new params[:name]
  halt 404 unless seed.exists? params[:version]
  content_type :tar
  send_file seed.path_for params[:version]
end
