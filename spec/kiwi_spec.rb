
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
end