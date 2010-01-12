
KIWI = File.dirname(__FILE__) + '../bin/kiwi'

def kiwi *args
  `./#{KIWI} #{args.join(' ')}`
end

describe "Kiwi" do
  it "should description" do
    
  end
end