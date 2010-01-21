
require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'yaml'
require 'sinatra'
require 'fileutils'
require 'server/helpers'
require 'server/models'
require 'server/seed'
require 'server/routes'
require 'digest/md5'

configure :test do
  DataMapper.setup :default, 'sqlite3::memory:'
  DataMapper.auto_migrate!
end