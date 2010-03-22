
require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-timestamps'
require 'yaml'
require 'sinatra'
require 'fileutils'
require 'digest/md5'
require 'server/models'

configure :test do
  set :seed_path, File.dirname(__FILE__) + '/../seeds'
  DataMapper.setup :default, 'sqlite3::memory:'
  DataMapper.auto_migrate!
  user = User.create :name => 'tj', :password => 'foobar'
  crypto = user.seeds.create :name => 'crypto'
  crypto.versions.create :number => '0.0.3', :description => ''
  haml = user.seeds.create :name => 'haml'
  haml.versions.create :number => '0.1.1', :description => 'Haml template engine'
  oo = user.seeds.create :name => 'oo'
  oo.versions.create :number => '1.1.0', :description => 'Class implementation'
  oo.versions.create :number => '1.2.0', :description => 'Class implementation'
  sass = user.seeds.create :name => 'sass'
  sass.versions.create :number => '0.0.1', :description => 'Sass to css compiler'
  express = user.seeds.create :name => 'express'
  express.versions.create :number => '0.0.1', :description => 'Sinatra-like web framework'
end

configure :production do
  set :seed_path, '/var/www/seeds'
  DataMapper.setup :default, File.read('/home/admin/.kiwi-mysql').strip
end

require 'server/helpers'
require 'server/routes'

SEEDS = File.expand_path Sinatra::Application.seed_path