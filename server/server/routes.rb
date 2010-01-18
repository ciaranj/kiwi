
##
# Search seeds, all are listed unless filtered by:
#
#  - :name
#

get '/search/?' do
  Kiwi::Seed.names.map do |name|
    next if params[:name] && !name.include?(params[:name])
    '%15s : %s' % [name, Kiwi::Seed.new(name).versions.reverse.join(' ')]
  end.compact.join("\n") + "\n"
end

##
# Output latest version for seed _name_.

get '/:name/latest/?' do
  Kiwi::Seed.new(params[:name]).versions.first
end

##
# Resolve the given :version for seed _name_.

get '/:name/resolve/?' do
  not_found ':version required.' unless params[:version]
  Kiwi::Seed.new(params[:name]).resolve params[:version]
end

##
# Transfer _version_ of the requested seed _name_.

get '/:name/:version/?' do
  seed = Kiwi::Seed.new params[:name]
  not_found 'seed does not exist.' unless seed.exists? params[:version]
  content_type :tar
  send_file seed.path_for params[:version]
end

##
# Publish seed _name_. Requires _seed_ archive and _info_ file.

post '/:name/?' do
  name = params[:name]
  seed = params[:seed]
  info = params[:info]
  halt 500, '<version>.seed required' unless seed
  halt 500, 'seed.yml required' unless info
  version = File.basename seed[:filename], '.seed'
  halt 500, '<version> is invalid; must be formatted as "n.n.n"' unless version =~ /\A\d+\.\d+\.\d+\z/
  FileUtils.mkdir_p SEEDS + "/#{name}"
  FileUtils.mv seed[:tempfile].path, SEEDS + "/#{name}/#{version}.seed", :force => true
  FileUtils.mv info[:tempfile].path, SEEDS + "/#{name}/#{version}.yml", :force => true
  "published #{name} #{version}\n"
end