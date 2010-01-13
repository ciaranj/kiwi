
require 'rubygems'
require 'sinatra'

##
# Transfer the requested seed when present.

get '/*.seed' do |name|
  p name
end