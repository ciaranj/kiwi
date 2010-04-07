
describe "GET /seeds/:name/info" do
  before :each do
    DataMapper.auto_migrate!
    @user = User.create :name => 'foo', :password => 'bar'
    @sass = @user.seeds.create :name => 'sass'
    @sass.versions.create :number => '0.0.1', :description => 'Sass to css engine'
    @sass.versions.create :number => '0.0.2', :description => 'Sass to css engine', :info => 'foobar'
  end
  
  it "should respond with seed yml" do
    get '/seeds/sass/info'
    last_response.should be_ok
    last_response.body.should include('foobar')
  end
end