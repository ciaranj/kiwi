
##
# Register user via HTTP basic auth credentials.

post '/user' do
  name, password = credentials
  user = User.new :name => name, :password => Digest::MD5.hexdigest(password)
  if user.save :register
    'registration successful'
  else
    fail 'registration failed'
  end
end

##
# Search seeds, all are listed unless filtered by:
#
#  - :name
#

get '/search/?' do
  Kiwi::Seed.names.map do |name|
    next if params[:name] and not name.include? params[:name]
    '%15s : %s' % [name, Kiwi::Seed.new(name).versions.reverse.join(' ')]
  end.compact.join("\n") + "\n"
end

##
# Resolve the given :version for seed _name_.

get '/:name/resolve/?' do
  seed = Kiwi::Seed.new params[:name]
  requires_seed seed
  if params[:version] && !params[:version].empty?
    seed.resolve(params[:version]) or not_found 'seed version does not exist.'
  else
    seed.current_version
  end
end

##
# Transfer _version_ of the requested seed _name_.

get '/:name/:version/?' do
  seed = Kiwi::Seed.new params[:name]
  requires_seed seed
  requires_seed seed, params[:version]
  content_type :tar
  send_file seed.path_for(params[:version])
end

##
# Publish seed _name_. Requires _seed_ archive and _info_ file.

post '/:name/?' do
  state = :published
  name, password = credentials
  user = User.first(:name => name, :password => Digest::MD5.hexdigest(password)) || halt(500, 'failed to authenticate, register first')
  name = params[:name]
  seed = params[:seed]
  info = params[:info]
  if inst = Seed.first(:name => name)
    if inst.user == user
      state = :overwrote
    else
      fail "unauthorized to publish #{name}"
    end
  else
    user.seeds.create :name => name
    state = :registered
  end
  fail '<version>.seed required' unless seed
  fail 'seed.yml required' unless info
  version = File.basename seed[:filename], '.seed'
  fail '<version> is invalid; must be formatted as "n.n.n"' unless version =~ /\A\d+\.\d+\.\d+\z/
  FileUtils.mkdir_p SEEDS + "/#{name}"
  FileUtils.mv seed[:tempfile].path, SEEDS + "/#{name}/#{version}.seed", :force => true
  FileUtils.mv info[:tempfile].path, SEEDS + "/#{name}/#{version}.yml", :force => true
  "Succesfully #{state} #{name} #{version}\n"
end