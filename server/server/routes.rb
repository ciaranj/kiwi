
require 'dm-core'
require 'dm-validations'
require 'digest/md5'

DataMapper.setup :default, 'sqlite3::memory:'

# TODO: halt 500 -> #error ?

class User
  include DataMapper::Resource
  property :id,       Serial
  property :name,     String, :index => true, :required => true
  property :password, String, :index => true, :required => true
  validates_is_unique :name, :on => :register
  has n, :seeds
end

class Seed
  include DataMapper::Resource
  property :id,       Serial
  property :name,     String, :index => true, :required => true
  validates_is_unique :name, :on => :register
  belongs_to :user
end

DataMapper.auto_migrate!

helpers do
  def credentials
    auth ||=  Rack::Auth::Basic::Request.new request.env
    halt 500, 'http basic auth credentials required' unless auth.provided? && auth.basic?
    auth.credentials
  end
end

get '/user' do
  name, password = credentials
  user = User.first :name => name, :password => Digest::MD5.hexdigest(password)
  "user #{name}:#{password} currently has #{user.seeds.length} seeds: " + user.seeds.map{ |seed| seed.name }.join(', ')
end

post '/user' do
  name, password = credentials
  user = User.new :name => name, :password => Digest::MD5.hexdigest(password)
  if user.save :register
    'registration successful'
  else
    halt 500, 'registration failed'
  end
end

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
# Resolve the given :version for seed _name_.

get '/:name/resolve/?' do
  seed = Kiwi::Seed.new params[:name]
  if params[:version] && !params[:version].empty?
    seed.resolve params[:version]
  else
    seed.current_version
  end
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
  name, password = credentials
  user = User.first(:name => name, :password => Digest::MD5.hexdigest(password)) || halt(500, 'failed to authenticate, register first')
  name = params[:name]
  seed = params[:seed]
  info = params[:info]
  if inst = Seed.first(:name => name)
    unless inst.user == user
      halt 500, "unauthorized to publish #{name}"
    end
  else
    user.seeds.create :name => name
  end
  halt 500, '<version>.seed required' unless seed
  halt 500, 'seed.yml required' unless info
  version = File.basename seed[:filename], '.seed'
  halt 500, '<version> is invalid; must be formatted as "n.n.n"' unless version =~ /\A\d+\.\d+\.\d+\z/
  FileUtils.mkdir_p SEEDS + "/#{name}"
  FileUtils.mv seed[:tempfile].path, SEEDS + "/#{name}/#{version}.seed", :force => true
  FileUtils.mv info[:tempfile].path, SEEDS + "/#{name}/#{version}.yml", :force => true
  "Succesfully published #{name} #{version}\n"
end