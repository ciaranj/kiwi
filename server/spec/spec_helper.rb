
$:.unshift File.dirname(__FILE__) + '/../' 
require 'config/environment'
require 'rack/test'

Spec::Runner.configure do |c|
  c.include Rack::Test::Methods
  c.include Module.new {
    def app
      Sinatra::Application
    end
  }
end