
describe "POST /:name" do
  before :each do
    DataMapper.auto_migrate!
    @joe = User.create :name => 'joe', :password => 'foobar'
    @bob = User.create :name => 'bob', :password => 'foobar'
    @sass = @bob.seeds.create :name => 'sass'
  end
  
  describe "when not given authentication" do
    it "should respond with 500" do
      post '/sass'
      last_response.status.should == 500
      last_response.body.should include('http basic auth credentials required')
    end
  end
  
  describe "when :name is not owned" do
    it "should respond with 500" do
      post '/sass', {}, basic_auth(:joe, :foobar)
      last_response.status.should == 500
      last_response.body.should include('unauthorized to publish sass')
    end
  end
  
  describe "when :name does not exist" do
    it "should publish the seed" do
      tarball = Rack::Test::UploadedFile.new '../server/seeds/oo/1.1.0.seed', 'application/x-tar-gzip'
      info = Rack::Test::UploadedFile.new '../server/seeds/oo/1.1.0.yml', 'text/yaml'
      post '/oo', { :seed => tarball, :info => info }, basic_auth(:joe, :foobar)
      last_response.should be_ok
      last_response.body.should include('Succesfully registered oo 1.1.0')
    end
  end
end