
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

describe "GET /search" do
  it "should respond with a formatted list of available seeds / versions" do
    get '/search'
    last_response.should be_ok
    last_response.body.should include("sass : 0.0.1\n")
  end
end