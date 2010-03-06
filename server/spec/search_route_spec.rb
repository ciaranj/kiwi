
describe "GET /search" do
  before :each do
    DataMapper.auto_migrate!
    @user = User.create :name => 'foo', :password => 'bar'
    @sass = @user.seeds.create :name => 'sass'
    @sass.versions.create :number => '0.0.1', :description => 'Sass to css engine'
    @oo = @user.seeds.create :name => 'oo'
    @oo.versions.create :number => '1.2.0', :description => 'Class implementation for JavaScript'  
    @oo.versions.create :number => '1.1.0', :description => 'Class implementation'  
  end
  
  it "should respond with a formatted list of available seeds and the latest version" do
    get '/search'
    last_response.should be_ok
    last_response.body.should include("sass : 0.0.1")
    last_response.body.should include("  oo : 1.2.0")
    last_response.body.should_not include('1.1.0')
  end
  
  describe "given :name" do
    it "should respond with only matching seed names" do
      get '/search?name=ass'
      last_response.should be_ok
      last_response.body.should include("sass : 0.0.1")
      last_response.body.should_not include("  oo")
    end
  end
end