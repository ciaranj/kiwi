
$:.unshift File.dirname(__FILE__) 
require 'rubygems'
require 'sinatra'
require 'fileutils'
require 'version_sorter'
require 'yaml'
require 'server/helpers'
require 'server/seed'
require 'server/routes'

run Sinatra::Application