
require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'yaml'
require 'sinatra'
require 'fileutils'
require 'digest/md5'
require 'server/models'

configure do
  set :seed_path, File.dirname(__FILE__) + '/../seeds'
  DataMapper.setup :default, 'sqlite3::memory:'
  DataMapper.auto_migrate!
end

configure :test do
  DataMapper.setup :default, 'sqlite3::memory:'
  DataMapper.auto_migrate!
end

configure :production do
  set :seed_path, '/var/www/seeds'
  DataMapper.setup :default, File.read('/home/admin/.kiwi-mysql').strip
end

require 'server/helpers'
require 'server/routes'