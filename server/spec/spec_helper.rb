
ENV['RACK_ENV'] = 'test'

$:.unshift File.dirname(__FILE__) + '/../' 
require 'config/environment'
require 'rack/test'

Spec::Runner.configure do |c|
  c.include Rack::Test::Methods
  c.include Module.new {
    def app
      Sinatra::Application
    end
    
    def basic_auth user, password
      { 'HTTP_AUTHORIZATION' => 'Basic ' + ["#{user}:#{password}"].pack('m*') }
    end
  }
end