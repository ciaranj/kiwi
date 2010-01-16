
def kiwi *args
  `./bin/kiwi #{args.join(' ')}`
end

def fixture name
  File.dirname(__FILE__) + "/fixtures/#{name}"
end

def in_fixture name, &block
  Dir.chdir fixture(name), &block
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
  
  describe "--seeds" do
    it "should output seed directory" do
      kiwi('--seeds').should include('.kiwi/seeds')
    end
  end
  
  describe "search" do
    describe "" do
      it "should output a list of available seeds and their associated versions" do
        kiwi('search').should include('haml : 0.1.1')
        kiwi('search').should include('  oo : 1.1.0 1.2.0')
      end
    end
    
    describe "<pattern>" do
      it "should filter by name" do
        kiwi('search ml').should include('haml : 0.1.1')
        kiwi('search ml').should_not include('oo')
      end
    end
  end
  
  describe "uninstall" do
    describe "" do
      it "should abort with seed name required" do
        kiwi('uninstall').should include('seed name required')
      end
    end
    
    describe "<name>" do
      it "should uninstall all versions" do
        `mkdir -p ~/.kiwi/seeds/haml/0.1.1`
        kiwi('uninstall haml')
        File.directory?(File.expand_path('~/.kiwi/seeds/haml/0.1.1')).should be_false
        File.directory?(File.expand_path('~/.kiwi/seeds/haml')).should be_false
      end
      
      describe "<version>" do
        it "should uninstall the version specified" do
          `mkdir -p ~/.kiwi/seeds/haml/0.1.1`
          kiwi('uninstall haml 0.1.1')
          File.directory?(File.expand_path('~/.kiwi/seeds/haml/0.1.1')).should be_false
          File.directory?(File.expand_path('~/.kiwi/seeds/haml')).should be_true
        end
      end
    end
  end
  
  describe "install" do
    describe "" do
      it "should abort with seed name required" do
        kiwi('install').should include('seed name required')
      end
    end
    
    describe "<name>" do
      after :each do
        `rm -fr ~/.kiwi/seeds`
      end
      
      it "should setup ~/.kiwi/seeds" do
        kiwi('install haml')
        File.directory?(File.expand_path('~/.kiwi/seeds')).should be_true
      end
      
      it "should setup ~/.kiwi/seeds/<name>/<version>" do
        kiwi('install haml')
        File.directory?(File.expand_path('~/.kiwi/seeds/haml/0.1.1')).should be_true
      end
      
      it "should install the current version" do
        kiwi('install haml')
        File.directory?(File.expand_path('~/.kiwi/seeds/haml/0.1.1/lib')).should be_true
      end
      
      it "should remove the seed" do
        kiwi('install haml')
        File.file?(File.expand_path('~/.kiwi/seeds/haml/0.1.1/haml.seed')).should be_false
      end
      
      it "should abort when already installed" do
        `mkdir -p ~/.kiwi/seeds/haml/0.1.1`
        kiwi('install haml').should include('haml 0.1.1 is already installed')
      end
      
      describe "when build command is specified" do
        it "should execute the build command relative to the seed's directory" do
          # File.file?(File.expand_path('~/.kiwi/seeds/libxml/0.1.0/libxmljs.node')).should be_false
          # kiwi('install libxml')
          # File.file?(File.expand_path('~/.kiwi/seeds/libxml/0.1.0/libxmljs.node')).should be_true
        end
      end
      
      describe "<version>" do
        describe "when valid" do
          it "should install the given version" do
            kiwi('install haml 0.1.1')
            File.directory?(File.expand_path('~/.kiwi/seeds/haml/0.1.1/lib')).should be_true
          end
        end
        
        describe "when invalid" do
          it "should abort after tar figures out seed is invalid" do
            kiwi('install haml 9.9.9').should include('failed to unpack. Seed is invalid or corrupt')
            File.directory?(File.expand_path('~/.kiwi/seeds/haml/9.9.9')).should be_false
          end
        end
      end
    end
    
  end
end