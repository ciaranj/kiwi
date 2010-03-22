
describe "GET /stats" do
  before :each do
    DataMapper.auto_migrate!
    @user = User.create :name => 'foo', :password => 'bar'
    @user = User.create :name => 'bar', :password => 'baz'
    @sass = @user.seeds.create :name => 'sass'
    @sass.versions.create :number => '0.0.1', :description => 'Sass to css engine', :downloads => 2
    @sass.versions.create :number => '0.0.2', :description => 'Sass to css engine', :downloads => 5
    @oo = @user.seeds.create :name => 'oo'
    @oo.versions.create :number => '1.2.0', :description => 'Class implementation for JavaScript', :downloads => 1
    @oo.versions.create :number => '1.1.0', :description => 'Class implementation'  
  end
  
  it "should respond with total downloads" do
    get '/stats'
    last_response.should be_ok
    last_response.body.should include('downloads : 8')
  end
  
  it "should respond with total users" do
    get '/stats'
    last_response.should be_ok
    last_response.body.should include('users : 2')
  end
  
  it "should respond with total seeds" do
    get '/stats'
    last_response.should be_ok
    last_response.body.should include('seeds : 2')
  end
  
  it "should respond with total seed versions" do
    get '/stats'
    last_response.should be_ok
    last_response.body.should include('seed versions : 4')
  end
end