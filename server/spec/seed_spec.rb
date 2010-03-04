
describe Seed do
  before :each do
    DataMapper.auto_migrate!
    @user = User.create :name => 'foo', :password => 'bar'
    @sass = @user.seeds.create :name => 'sass'
    @sass.versions.create :number => '0.0.1', :description => 'Sass to css engine'
    @oo = @user.seeds.create :name => 'oo'
    @oo.versions.create :number => '1.2.0', :description => 'Class implementation for JavaScript'  
    @oo.versions.create :number => '1.1.0', :description => 'Class implementation' 
  end
  
  describe "#path" do
    it "should return a path to the seed's directory" do
      @oo.path.should include('server/seeds/oo')
    end
  end
  
  describe "#version_numbers" do
    it "should return an array of versions available" do
      @oo.version_numbers.should include('1.1.0', '1.2.0')
    end
  end
  
  describe "#current_version" do
    it "should return the latest Version" do
      @oo.current_version.should be_a(Version)
      @oo.current_version.number.should == '1.2.0'
    end
  end
  
  describe "#info" do
    it "should return yml info for the given version" do
      # TODO: move to version_spec.rb
      @oo.current_version.info['name'].should == 'oo'
    end
  end
  
  describe "#resolve" do
    describe "<version>" do
      it "should match exact version" do
        @oo.resolve('1.1.0').should == '1.1.0'
        @oo.resolve('9.9.9').should be_nil
      end
    end
    
    describe "= <version>" do
      it "should match exact version" do
        @oo.resolve('= 1.1.0').should == '1.1.0'
        @oo.resolve('= 9.9.9').should be_nil
      end
    end
    
    describe "> <version>" do
      it "should match greater than the given version" do
        @oo.resolve('> 1.1.0').should == '1.2.0'
        @oo.resolve('> 9.9.9').should be_nil
      end
    end
    
    describe ">= <version>" do
      it "should match greater than or equal to the given version" do
        @oo.resolve('>= 1.1.0').should == '1.2.0'
        @oo.resolve('>= 1.1.1').should == '1.2.0'
        @oo.resolve('>= 9.9.9').should be_nil
      end
    end
    
    describe ">~ <version>" do
      it "should match greater than or equal to the given version with compatibility" do
        @oo.resolve('>~ 1.0.0').should == '1.2.0'
        @oo.resolve('>~ 1.1.0').should == '1.2.0'
        @oo.resolve('>~ 1.2.0').should == '1.2.0'
        @oo.resolve('>~ 9.9.9').should be_nil
      end
    end
    
  end
end