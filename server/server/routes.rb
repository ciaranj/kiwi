
##
# Register user via HTTP basic auth credentials.

post '/user' do
  name, password = credentials
  user = User.new :name => name, :password => password
  if user.save :register
    "registration successful.\n"
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
  Seed.all.each do |seed|
    next if params[:name] and not seed.name.include? params[:name]
    '%15s : %s' % [seed.name, seed.version_numbers.join(' ')]
  end.compact.join("\n") + "\n"
end

##
# Resolve the given :version for seed _name_.

get '/:name/resolve/?' do
  require_seed params[:name]
  version = params[:version]
  if version and not version.empty?
    @seed.resolve(version) or not_found 'seed version does not exist.'
  else
    @seed.current_version.number
  end
end

##
# Transfer _version_ of the requested seed _name_.

get '/seeds/:name/:version.seed' do
  require_seed params[:name], params[:version]
  content_type :tar
  @version.update :downloads => @version.downloads + 1
  send_file @seed.path_for(@version.number)
end

##
# Publish seed _name_. Requires _seed_ archive and _info_ file.

post '/:name/?' do
  require_authentication
  state = :published
  name, seed, info = params[:name], params[:seed], params[:info]
  if inst = Seed.first(:name => name)
    if inst.user == @user
      state = :overwrote
    else
      fail "unauthorized to publish #{name}"
    end
  else
    inst = @user.seeds.create :name => name
    state = :registered
  end
  fail '<version>.seed required' unless seed
  fail 'seed.yml required' unless info
  version = File.basename seed[:filename], '.seed'
  fail '<version> is invalid; must be formatted as "n.n.n"' unless version =~ /\A\d+\.\d+\.\d+\z/
  FileUtils.mkdir_p SEEDS + "/#{name}"
  FileUtils.mv seed[:tempfile].path, SEEDS + "/#{name}/#{version}.seed", :force => true
  FileUtils.mv info[:tempfile].path, SEEDS + "/#{name}/#{version}.yml", :force => true
  inst.versions.first_or_create :number => version, :description => Kiwi::Seed.new(name).info(version)['description']
  "Succesfully #{state} #{name} #{version}.\n"
end