
class User
  
  #--
  # Mixins
  #++
  
  include DataMapper::Resource
  
  #--
  # Properties
  #++
  
  property :id,       Serial
  property :name,     String, :index => true, :required => true
  property :password, String, :index => true, :required => true
  
  #--
  # Validations
  #++
  
  validates_is_unique :name, :on => :register
  
  #--
  # Associations
  #++
  
  has n, :seeds
  
  #--
  # Hooks
  #++
  
  before :save do
    self.password = Digest::MD5.hexdigest(password) if new?
  end
end

class Seed
  
  #--
  # Mixins
  #++
  
  include DataMapper::Resource
  
  #--
  # Properties
  #++
  
  property :id,       Serial
  property :name,     String, :index => true, :required => true
  
  #--
  # Validations
  #++
  
  validates_is_unique :name, :on => :register
  validates_format :name, :format => /\A\w+\z/
  
  #--
  # Associations
  #++
  
  belongs_to :user
end