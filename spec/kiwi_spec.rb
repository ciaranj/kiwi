
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
  
  describe "--seeds" do
    it "should output seed directory" do
      kiwi('--seeds').should include('.kiwi/seeds')
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
        `mkdir -p ~/.kiwi/seeds/libxmljs/0.1.0`
        kiwi('uninstall libxmljs')
        File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0')).should be_false
        File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs')).should be_false
      end
      
      describe "<version>" do
        it "should uninstall the version specified" do
          `mkdir -p ~/.kiwi/seeds/libxmljs/0.1.0`
          kiwi('uninstall libxmljs 0.1.0')
          File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0')).should be_false
          File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs')).should be_true
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
        kiwi('install libxmljs')
        File.directory?(File.expand_path('~/.kiwi/seeds')).should be_true
      end
      
      it "should setup ~/.kiwi/seeds/<name>/<version>" do
        kiwi('install libxmljs')
        File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0')).should be_true
      end
      
      it "should install the current version" do
        kiwi('install libxmljs')
        File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0/src')).should be_true
      end
      
      it "should remove the seed" do
        kiwi('install libxmljs')
        File.file?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0/libxmljs.seed')).should be_false
      end
      
      it "should copy the metadata file" do
        kiwi('install libxmljs')
        File.file?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0/libxmljs.yml')).should be_true
      end
      
      it "should abort when already installed" do
        `mkdir -p ~/.kiwi/seeds/libxmljs/0.1.0`
        kiwi('install libxmljs').should include('libxmljs 0.1.0 is already installed')
      end
      
      describe "<version>" do
        describe "when valid" do
          it "should install the given version" do
            kiwi('install libxmljs 0.1.0')
            File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/0.1.0/src')).should be_true
          end
        end
        
        describe "when invalid" do
          it "should abort after tar figures out seed is invalid" do
            kiwi('install libxmljs 9.9.9').should include('failed to unpack. Seed is invalid or corrupt')
            File.directory?(File.expand_path('~/.kiwi/seeds/libxmljs/9.9.9')).should be_false
          end
        end
      end
    end
    
  end
end