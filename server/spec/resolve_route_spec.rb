
describe "GET /:name/resolve" do
  describe "when :name does not exist" do
    it "should respond with 404" do
      get '/invalid/resolve'
      last_response.status.should == 404
      last_response.body.should include('seed does not exist')
    end
  end
  
  describe "when :name exists" do
    it "should respond with the current version" do
      get '/oo/resolve'
      last_response.should be_ok
      last_response.body.should == '1.2.0'
    end
    
    describe "given :version" do
      describe "when valid" do
        it "should respond with the matching version" do
          get '/oo/resolve?version=1.1.0'
          last_response.should be_ok
          last_response.body.should == '1.1.0'
        end
      end
      
      describe "when invalid" do
        it "should respond with 404" do
          get '/oo/resolve?version=9.9.9'
          last_response.status.should == 404
          last_response.body.should include('version does not exist')
        end
      end
    end
  end
end