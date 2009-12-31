
describe 'Kiwi'
  describe '.version'
    it 'should be a triplet'
      Kiwi.version.should.match(/^\d+\.\d+\.\d+$/)
    end
  end
end