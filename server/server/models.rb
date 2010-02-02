
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

class Version
  
  #--
  # Mixins
  #++
  
  include DataMapper::Resource
  
  #--
  # Properties
  #++
  
  property :id,          Serial
  property :build,       String,   :index => true
  property :version,     String,   :index => true, :required => true, :format => /\A\d+\.\d+\.\d+\z/
  property :description, String,   :index => true
  property :created_at,  DateTime, :index => true
  property :updated_at,  DateTime, :index => true
  
  #--
  # Associations
  #++
  
  belongs_to :seed
  
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
  has n, :versions
  
end