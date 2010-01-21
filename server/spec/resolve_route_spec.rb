
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
      
    end
    
    describe "given :version" do
      describe "when valid" do
        it "should respond with the matching version" do
          
        end
      end
      
      describe "when invalid" do
        it "should respond with 404" do
          
        end
      end
    end
  end
end