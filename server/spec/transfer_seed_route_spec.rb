
describe "GET /seeds/:name/:version.seed" do
  before :each do
    DataMapper.auto_migrate!
    @user = User.create :name => 'tj', :password => 'foobar'
    @oo = @user.seeds.create :name => 'oo'
    @oo.versions.create :version => '1.2.0'  
  end
  
  describe "when seed does not exist" do
    it "should respond with 404" do
      get '/seeds/invalid/9.9.9.seed'
      last_response.status.should == 404
      last_response.body.should include('seed does not exist')
    end
  end
  
  describe "when seed version does not exist" do
    it "should respond with 404" do
      get '/seeds/oo/9.9.9.seed'
      last_response.status.should == 404
      last_response.body.should include('seed version does not exist')
    end
  end
  
  describe "when seed and version exist" do
    it "should transfer seed tarball when :version exists" do
      get '/seeds/oo/1.2.0.seed'
      last_response.should be_ok
      last_response.headers['Content-Type'].should == 'application/x-tar'
    end
    
    it "should bump download count" do
      get '/seeds/oo/1.2.0.seed'
      last_response.should be_ok
      @oo.reload.versions.first(:version => '1.2.0').downloads.should == 1
    end
  end
end