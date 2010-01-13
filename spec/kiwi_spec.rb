
def kiwi *args
  `./bin/kiwi #{args.join(' ')}`
end

describe "Kiwi" do
  it "should description" do
    kiwi('--version').should match(/^\d+\.\d+\.\d+$/)
  end
end