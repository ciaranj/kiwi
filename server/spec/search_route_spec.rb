
describe "GET /search" do
  it "should respond with a formatted list of available seeds / versions" do
    get '/search'
    last_response.should be_ok
    last_response.body.should include("sass : 0.0.1")
    last_response.body.should include("  oo : 1.2.0")
  end
  
  describe "given :name" do
    it "should respond with only matching seed names" do
      get '/search?name=ass'
      last_response.should be_ok
      last_response.body.should include("sass : 0.0.1")
      last_response.body.should_not include("  oo : 1.2.0")
    end
  end
end