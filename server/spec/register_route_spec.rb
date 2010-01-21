
describe "POST /user" do
  describe "when given HTTP basic auth" do
    it "should description" do
      post '/user'
      last_response.should be_ok
      last_response.body.should include('registration successful')
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