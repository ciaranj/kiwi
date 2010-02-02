
describe "POST /:name" do
  before :each do
    DataMapper.auto_migrate!
    @joe = User.create :name => 'joe', :password => 'foobar'
    @bob = User.create :name => 'bob', :password => 'foobar'
    @sass = Seed.create :name => 'sass', :user => @bob
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
    it "should publish" do
      # post '/something', { :seed => '', :info => '' }, basic_auth(:joe, :foobar)
      # last_response.should be_ok
      # last_response.body.should include('Succesfully registered something 0.0.1')
    end
  end
end