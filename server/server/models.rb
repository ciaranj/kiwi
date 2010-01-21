
class User
  include DataMapper::Resource
  property :id,       Serial
  property :name,     String, :index => true, :required => true
  property :password, String, :index => true, :required => true
  validates_is_unique :name, :on => :register
  has n, :seeds
  
  before :save do
    self.password = Digest::MD5.hexdigest(password) if new?
  end
end

class Seed
  include DataMapper::Resource
  property :id,       Serial
  property :name,     String, :index => true, :required => true
  validates_is_unique :name, :on => :register
  belongs_to :user
end