
def kiwi *args
  `export SERVER_ADDR=0.0.0.0; export SERVER_PORT=8888; #{File.dirname(__FILE__)}/../bin/kiwi #{args.join(' ')}`
end

def fixture name
  File.dirname(__FILE__) + "/fixtures/#{name}"
end

def in_fixture name, &block
  Dir.chdir fixture(name), &block
end

kiwi('switch test')

describe "Kiwi" do
  after :each do
    `rm -fr ~/.kiwi/test ~/.kiwi/current ~/.kiwi/.auth`  
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
  
  describe "register" do
    describe "" do
      it "should abort with user name required" do
        kiwi('register').should include('user name required')
      end
    end
    
    describe "<user>" do
      it "should abort with password required" do
        kiwi('register tj').should include('password required')
      end
    end
  end
  
  describe "whoami" do
    it "should output auth help when not registered" do
      kiwi('whoami').should include('Credentials cannot be found')
      kiwi('whoami').should include('If you have previously registered simply run:')
    end
    
    it "should output username when registered" do
      kiwi('register foo bar')
      kiwi('whoami').should include('foo')
      kiwi('whoami').should_not include('bar')
    end
  end
  
  describe "list" do
    describe "when nothing is installed" do
      it "should output an error message" do
        kiwi('list').should include('no seeds are installed')
      end
    end
    
    describe "when installed" do
      it "should output a list of installed seeds" do
        kiwi('install haml')
        kiwi('install oo 1.1.0')
        kiwi('install oo 1.2.0')
        kiwi('list').should include('haml : 0.1.1')
        kiwi('list').should include('  oo : 1.1.0 1.2.0')
      end
    end
  end
  
  describe "search" do
    describe "" do
      it "should output a list of available seeds and the latest version" do
        kiwi('search').should include('haml : 0.1.1')
        kiwi('search').should include('  oo : 1.2.0')
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
        `rm -fr ~/.kiwi/trying_new_stuff`
      end
    end
  end
  
  describe "uninstall" do
    it "should not remove seed directories which contain seeds" do
      kiwi('install oo 1.1.0')
      kiwi('install oo 1.2.0')
      kiwi('uninstall oo 1.1.0')
      File.directory?(File.expand_path('~/.kiwi/current/seeds/oo')).should be_true
      File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.2.0')).should be_true
      File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.1.0')).should be_false
    end
    
    it "should remove empty seed directories" do
      kiwi('install oo 1.1.0')
      kiwi('uninstall oo 1.1.0')
      File.directory?(File.expand_path('~/.kiwi/current/seeds/oo')).should be_false
    end
    
    describe "" do
      it "should abort with seed name required" do
        kiwi('uninstall').should include('seed name required')
      end
    end
    
    describe "<name>" do
      it "should uninstall all versions" do
        kiwi('install oo 1.2.0')
        kiwi('install oo 1.1.0')
        kiwi('uninstall oo')
        File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.1.0')).should be_false
        File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.2.0')).should be_false
        File.directory?(File.expand_path('~/.kiwi/current/seeds/oo')).should be_false
      end
      
      describe "<version>" do
        it "should uninstall the version specified" do
          kiwi('install oo 1.2.0')
          kiwi('install oo 1.1.0')
          kiwi('uninstall oo 1.1.0')
          File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.2.0')).should be_true
          File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.1.0')).should be_false
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
        File.directory?(File.expand_path('~/.kiwi/current/seeds/crypto/0.0.3')).should be_true
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
      
      it "should work when published via kiwi" do
        in_fixture :valid do
          kiwi('register foo bar')
          kiwi('release foo 0.1.1').should include('Successfully')
          kiwi('install foo 0.1.1')
          File.directory?(File.expand_path('~/.kiwi/current/seeds/foo/0.1.1')).should be_true
          File.file?(File.expand_path('~/.kiwi/current/seeds/foo/0.1.1/seed.yml')).should be_true
        end
        `rm -fr server/seeds/foo`
      end
      
      it "should install dependencies" do
        kiwi('install express')
        File.directory?(File.expand_path('~/.kiwi/current/seeds/express/0.0.1')).should be_true
        File.directory?(File.expand_path('~/.kiwi/current/seeds/haml/0.1.1')).should be_true
        File.directory?(File.expand_path('~/.kiwi/current/seeds/sass/0.0.1')).should be_true
        File.directory?(File.expand_path('~/.kiwi/current/seeds/oo/1.2.0')).should be_true
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