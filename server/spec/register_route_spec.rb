
describe "POST /user" do
  describe "when given HTTP basic auth" do
    describe "when the user does not exist" do
      it "should create the user" do
        post '/user', {}, 'HTTP_AUTHORIZATION' => 'Basic ' + ['foo:bar'].pack('m*')
        last_response.should be_ok
        last_response.body.should include('registration successful')
        User.first(:name => 'foo').should be_a(User)
      end
    end
    
    describe "when the user exists" do
      it "should respond with 500" do
        User.create :name => 'tj', :password => 'foobar'
        post '/user', {}, 'HTTP_AUTHORIZATION' => 'Basic ' + ['tj:bar'].pack('m*')
        last_response.status.should == 500
        last_response.body.should include('registration failed')
        User.first(:name => 'tj').password.should == 'foobar'
      end
    end
  end
  
  describe "when not given HTTP basic auth" do
    it "should respond with 500" do
      post '/user'
      last_response.status.should == 500
      last_response.body.should include('http basic auth credentials required')
    end
  end
end