
##
# Output kiwi statistics.

get '/stats' do
  format = '%15s : %d'
  [ format % ['users', User.count],
    format % ['downloads', Version.all.map{ |v| v.downloads }.inject(0) { |sum, n| sum + n }],
    format % ['seeds', Seed.count],
    format % ['seed versions', Version.count]
  ].join("\n") + "\n"
end

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
  name = params[:name]
  Seed.all(:order => [:name.asc]).map do |seed|
    next if name and not seed.name.include? name
    version = seed.current_version
    '%15s : %s - %s (%d)' % [seed.name, version.number, version.description, seed.downloads]
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
  send_file @version.path
end

##
# Publish seed _name_. Requires _seed_ archive and _info_ file.

post '/:name/?' do
  require_authentication
  state = :published
  name, tarball, info = params[:name], params[:seed], params[:info]

  # Verify ownership
  
  if seed = Seed.first(:name => name)
    fail "unauthorized to publish #{name}" if seed.user != @user
  else
    seed = @user.seeds.create :name => name
    state = :registered
  end
  
  # Validate files
  
  fail '<version>.seed tarball is required' unless tarball
  fail 'seed.yml is required' unless info
  version = File.basename tarball[:filename], '.seed'
  fail 'version is invalid; must be formatted as "n.n.n"' unless version =~ /\A\d+\.\d+\.\d+\z/
    
  # Save the seed data

  FileUtils.mkdir_p SEEDS + "/#{name}"
  FileUtils.mv tarball[:tempfile].path, SEEDS + "/#{name}/#{version}.seed", :force => true
  FileUtils.mv info[:tempfile].path, SEEDS + "/#{name}/#{version}.yml", :force => true
  
  # Update version data
  
  info = YAML.load_file SEEDS + "/#{name}/#{version}.yml"
  
  if seed.versions.first :number => version
    state = :replaced
  else
    seed.versions.create :number => version, :description => info['description']
  end
  
  "Successfully #{state} #{name} #{version}.\n"
end
