
def kiwi *args
  `#{File.dirname(__FILE__)}/../bin/kiwi #{args.join(' ')}`
end

def fixture name
  File.dirname(__FILE__) + "/fixtures/#{name}"
end

def in_fixture name, &block
  Dir.chdir fixture(name), &block
end

def mock_seed name, version
  `mkdir -p ~/.kiwi/current/seeds/#{name}/#{version}`
end

kiwi('switch test')

describe "Kiwi" do
  after :each do
    `rm -fr ~/.kiwi/current/seeds`  
  end
  
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
      kiwi('--seeds').should include('.kiwi/current/seeds')
    end
  end
  
  describe "search" do
    describe "" do
      it "should output a list of available seeds and their associated versions" do
        kiwi('search').should include('haml : 0.1.1')
        kiwi('search').should include('  oo : 1.2.0 1.1.0')
      end
    end
    
    describe "<pattern>" do
      it "should filter by name" do
        kiwi('search ml').should include('haml : 0.1.1')
        kiwi('search ml').should_not include('oo')
      end
    end
  end
  
  describe "update" do
    describe "with no seeds installed" do
      it "should abort" do
        kiwi('update').should include('no seeds are installed')
      end
    end
    
    describe "with several seeds installed" do
      it "should update them" do
        kiwi('install haml')
        kiwi('install oo')
        kiwi('-v update').should include('install : haml')
        kiwi('-v update').should include('install : oo')
      end
    end
  end
  
  describe "switch" do
    describe "" do
      it "should abort with environment name required" do
        kiwi('switch').should include('environment name required')
      end
    end
    
    describe "<env>" do
      it "should switch the current environment" do
        kiwi('switch trying_new_stuff')
        kiwi('install oo')
        File.directory?(File.expand_path('~/.kiwi/current/seeds/oo')).should be_true
        File.directory?(File.expand_path('~/.kiwi/trying_new_stuff/seeds/oo')).should be_true
        File.directory?(File.expand_path('~/.kiwi/test/seeds/oo')).should be_false
        kiwi('switch test')
      end
    end
  end
  
  describe "uninstall" do
    it "should not remove seed directories which contain seeds" do
      mock_seed :haml, '1.0.0'
      mock_seed :haml, '2.0.0'
      kiwi('uninstall haml 1.0.0')
      File.directory?(File.expand_path('~/.kiwi/current/seeds/haml')).should be_true
      File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/2.0.0')).should be_true
      File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/1.0.0')).should be_false
    end
    
    it "should remove empty seed directories" do
      mock_seed :haml, '1.0.0'
      kiwi('uninstall haml 1.0.0')
      File.directory?(File.expand_path('~/.kiwi/current/seeds/haml')).should be_false
    end
    
    describe "" do
      it "should abort with seed name required" do
        kiwi('uninstall').should include('seed name required')
      end
    end
    
    describe "<name>" do
      it "should uninstall all versions" do
        mock_seed :haml, '0.1.1'
        kiwi('uninstall haml')
        File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1')).should be_false
        File.directory?(File.expand_path('~/.kiwi/current/seeds/haml')).should be_false
      end
      
      describe "<version>" do
        it "should uninstall the version specified" do
          mock_seed :haml, '0.1.1'
          kiwi('uninstall haml 0.1.1')
          File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1')).should be_false
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
    
    describe "<file>" do
      it "should install from a flat-list of seeds" do
        kiwi('install ' + fixture('seeds'))
        File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1')).should be_true
        File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.2.0')).should be_true
      end
    end
    
    describe "<name>" do
      it "should setup ~/.kiwi/current/seeds" do
        kiwi('install haml')
        File.directory?(File.expand_path('~/.kiwi/current/seeds')).should be_true
      end
      
      it "should setup ~/.kiwi/current/seeds/<name>/<version>" do
        kiwi('install haml')
        File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1')).should be_true
      end
      
      it "should install the current version" do
        kiwi('install haml')
        File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1/lib')).should be_true
      end
      
      it "should remove the seed" do
        kiwi('install haml')
        File.file?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1/haml.seed')).should be_false
      end
      
      it "should skip when already installed" do
        kiwi('install haml')
        kiwi('-v install haml').should include('already installed')
      end
      
      describe "when build command is specified" do
        it "should execute the build command relative to the seed's directory" do
          File.file?(File.expand_path('~/.kiwi/current/seeds/crypto/0.0.3/crypto.node')).should be_false
          kiwi('install crypto "= 0.0.3"')
          File.file?(File.expand_path('~/.kiwi/current/seeds/crypto/0.0.3/crypto.node')).should be_true
        end
      end
      
      describe "<version>" do
        describe "when valid" do
          it "should install the given version" do
            kiwi('install oo "= 1.1.0"')
            File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.1.0/lib')).should be_true
          end
        end
        
        describe "when invalid" do
          it "should abort after tar figures out the seed is invalid" do
            kiwi('install haml "= 9.9.9"').should include('failed to unpack. Seed is invalid or corrupt')
            File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/9.9.9')).should be_false
          end
        end
        
        describe "when valid without operator" do
          it "should install the given version" do
            kiwi('install oo 1.1.0')
            File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.1.0/lib')).should be_true
          end
        end
        
        describe "when invalid without operator" do
          it "should abort after tar figures out the seed is invalid" do
            kiwi('install haml 9.9.9').should include('failed to unpack. Seed is invalid or corrupt')
            File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/9.9.9')).should be_false
          end
        end
      end
    end
    
    describe "build" do
      it "should abort with seed version required" do
        kiwi('build').should include('seed version required')
      end
      
      describe "<version>" do
        describe "when seed.yml is present" do
          it "should build <version>.seed" do
            in_fixture :valid do
              kiwi('build 0.1.1')
              File.exists?('0.1.1.seed').should be_true
              `rm 0.1.1.seed`
            end
          end
        end
        
        describe "when seed.yml is not present" do
          it "should abort with seed.yml file required" do
            in_fixture :invalid do
              kiwi('build 0.1.1').should include('seed.yml file required')
            end
          end
        end
        
        it "should respect .ignore" do
          in_fixture :valid do
            kiwi('build 0.1.1')
            contents = `tar --list -zf 0.1.1.seed`
            contents.should include('.foo')
            contents.should include('.ignore')
            contents.should_not include('foo.log')
            contents.should_not include('pkg')
            contents.should_not include('pkg/blah.js')
            contents.should_not include('lib/haml.something')
            `rm 0.1.1.seed`
          end
        end
        
        it "should exclude scms .git, .svn, .csv" do
          in_fixture :valid do
            kiwi('build 0.1.1')
            contents = `tar --list -zf 0.1.1.seed`
            contents.should_not include(".git\n")
            contents.should_not include(".svn\n")
            contents.should_not include(".cvs\n")
            `rm 0.1.1.seed`
          end
        end
        
      end
    end
    
  end
end