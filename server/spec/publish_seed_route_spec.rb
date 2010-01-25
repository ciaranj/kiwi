
describe "POST /:name" do
  describe "when not given authentication" do
    it "should respond with 500" do
      post '/sass'
      last_response.status.should == 500
      last_response.body.should include('http basic auth credentials required')
    end
  end
end

__END__

##
# Publish seed _name_. Requires _seed_ archive and _info_ file.

post '/:name/?' do
  require_authentication
  state = :published
  name, seed, info = params[:name], params[:seed], params[:info]
  if inst = Seed.first(:name => name)
    if inst.user == @user
      state = :overwrote
    else
      fail "unauthorized to publish #{name}"
    end
  else
    @user.seeds.create :name => name
    state = :registered
  end
  fail '<version>.seed required' unless seed
  fail 'seed.yml required' unless info
  version = File.basename seed[:filename], '.seed'
  fail '<version> is invalid; must be formatted as "n.n.n"' unless version =~ /\A\d+\.\d+\.\d+\z/
  FileUtils.mkdir_p SEEDS + "/#{name}"
  FileUtils.mv seed[:tempfile].path, SEEDS + "/#{name}/#{version}.seed", :force => true
  FileUtils.mv info[:tempfile].path, SEEDS + "/#{name}/#{version}.yml", :force => true
  "Succesfully #{state} #{name} #{version}.\n"
end