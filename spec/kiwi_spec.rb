
def kiwi *args
  `./bin/kiwi #{args.join(' ')}`
end

describe "Kiwi" do
  describe "--version" do
    it "should output version triplet" do
      kiwi('--version').should match(/^\d+\.\d+\.\d+$/)
    end
  end
  
  describe "--help" do
    it "should output help information" do
      kiwi('--help').should include('Usage')
    end
  end
  
  describe "install" do
    describe "with no arguments" do
      it "should abort with seed name required" do
        kiwi('install').should include('seed name required')
      end
    end
    
    describe "<name>" do
      before :each do
        kiwi('install libxmljs')  
      end
      
      after :each do
        `rm -fr ~/.kiwi/seeds`
      end
      
      it "should setup ~/.kiwi/seeds" do
        File.directory?(File.expand_path('~/.kiwi/seeds')).should be_true
      end
      
      it "should setup ~/.kiwi/seeds/<name>/<version>" do
        File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0')).should be_true
      end
      
      it "should install the current version" do
        File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0/src')).should be_true
      end
    end
  end
end