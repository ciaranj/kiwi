
require 'rubygems'
require 'sinatra'

##
# Transfer the requested seed when present.

get '/:seed/:version?' do
  p params
end