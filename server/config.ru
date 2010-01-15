
$:.unshift File.dirname(__FILE__) 
require 'rubygems'
require 'sinatra'
require 'fileutils'
require 'yaml'
require 'server/seed'
require 'server/routes'

run Sinatra::Application