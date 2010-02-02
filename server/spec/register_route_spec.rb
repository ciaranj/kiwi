
describe "POST /user" do
  describe "when given HTTP basic auth" do
    describe "when the user does not exist" do
      it "should create the user" do
        post '/user', {}, basic_auth(:foo, :bar)
        last_response.should be_ok
        last_response.body.should include('registration successful')
        User.first(:name => 'foo').should be_a(User)
      end
      
      it "should md5 hash the password" do
        post '/user', {}, basic_auth(:someone, :awesome)
        last_response.should be_ok
        last_response.body.should include('registration successful')
        User.first(:name => 'someone').password.should == 'be121740bf988b2225a313fa1f107ca1'
      end
    end
    
    describe "when the user exists" do
      it "should respond with 500" do
        User.create :name => 'tj', :password => 'foobar'
        post '/user', {}, basic_auth(:tj, :bar)
        last_response.status.should == 500
        last_response.body.should include('registration failed')
        User.first(:name => 'tj').password.should == '3858f62230ac3c915f300c664312c63f'
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