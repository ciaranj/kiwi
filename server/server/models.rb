
class User
  
  #--
  # Mixins
  #++
  
  include DataMapper::Resource
  
  #--
  # Properties
  #++
  
  property :id,         Serial
  property :name,       String,   :index => true, :required => true
  property :password,   String,   :index => true, :required => true
  property :created_at, DateTime, :index => true  
  property :updated_at, DateTime, :index => true  
  
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
  
  property :id,          Serial
  property :name,        String,   :index => true, :required => true, :format => /\A\w+\z/
  property :build,       String,   :index => true
  property :description, String,   :index => true
  property :created_at,  DateTime, :index => true
  property :updated_at,  DateTime, :index => true
  
  #--
  # Validations
  #++
  
  validates_is_unique :name, :on => :register
  
  #--
  # Associations
  #++
  
  belongs_to :user
end