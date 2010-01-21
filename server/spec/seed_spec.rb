
describe Kiwi::Seed do
  before :each do
    @seed = Kiwi::Seed.new 'oo'  
  end
  
  describe "#path" do
    it "should return a path to the seed's directory" do
      @seed.path.should include('server/seeds/oo')
    end
  end
  
  describe "#versions" do
    it "should return an array of versions available" do
      @seed.versions.should include('1.1.0', '1.2.0')
    end
  end
  
  describe "#current_version" do
    it "should return the latest version" do
      @seed.current_version.should == '1.2.0'
    end
  end
  
  describe "#info" do
    it "should return yml info for the given version" do
      @seed.info('1.1.0')['name'].should == 'oo'
    end
  end
  
  describe "#resolve" do
    describe "<version>" do
      it "should match exact version" do
        @seed.resolve('1.1.0').should == '1.1.0'
        @seed.resolve('9.9.9').should be_nil
      end
    end
    
    describe "= <version>" do
      it "should match exact version" do
        @seed.resolve('= 1.1.0').should == '1.1.0'
        @seed.resolve('= 9.9.9').should be_nil
      end
    end
    
    describe "> <version>" do
      it "should match greater than the given version" do
        @seed.resolve('> 1.1.0').should == '1.2.0'
        @seed.resolve('> 9.9.9').should be_nil
      end
    end
    
    describe ">= <version>" do
      it "should match greater than or equal to the given version" do
        @seed.resolve('>= 1.1.0').should == '1.2.0'
        @seed.resolve('>= 1.1.1').should == '1.2.0'
        @seed.resolve('>= 9.9.9').should be_nil
      end
    end
    
    describe ">~ <version>" do
      it "should match greater than or equal to the given version with compatibility" do
        @seed.resolve('>~ 1.0.0').should == '1.2.0'
        @seed.resolve('>~ 1.1.0').should == '1.2.0'
        @seed.resolve('>~ 1.2.0').should == '1.2.0'
        @seed.resolve('>~ 9.9.9').should be_nil
      end
    end
    
  end
end