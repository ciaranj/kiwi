
describe "GET /:name/resolve" do
  before :each do
    DataMapper.auto_migrate!
    @user = User.create :name => 'foo', :password => 'bar'
    @sass = @user.seeds.create :name => 'sass'
    @sass.versions.create :number => '0.0.1', :description => 'Sass to css engine'
    @oo = @user.seeds.create :name => 'oo'
    @oo.versions.create :number => '1.2.0', :description => 'Class implementation for JavaScript'  
    @oo.versions.create :number => '1.1.0', :description => 'Class implementation'  
  end
  
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