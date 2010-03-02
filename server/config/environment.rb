
require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'yaml'
require 'sinatra'
require 'fileutils'
require 'server/helpers'
require 'server/models'
require 'server/seed'
require 'server/routes'
require 'digest/md5'

configure do
  DataMapper.setup :default, 'sqlite3::memory:'
  DataMapper.auto_migrate!
end

configure :test do
  DataMapper.setup :default, 'sqlite3::memory:'
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper.setup :default, File.read('/home/admin/.kiwi-mysql').strip
end