
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
  property :number,      String,   :index => true, :required => true, :format => /\A\d+\.\d+\.\d+\z/
  property :description, String,   :index => true, :length => 0..255
  property :downloads,   Integer,  :index => true, :default => 0
  property :created_at,  DateTime, :index => true
  property :updated_at,  DateTime, :index => true
  
  #--
  # Associations
  #++
  
  belongs_to :seed
  
  #--
  # Instance methods
  #++
  
  ##
  # Return path to seed tarball.
  
  def path
    seed.path + "/#{number}.seed"
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
  property :name,        String,   :index => true, :required => true, :format => /\A[\w_-]+\z/
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
  
  #--
  # Instance methods
  #++
  
  ##
  # Return path to this seed.
  
  def path
    SEEDS + '/' + name
  end
  
  ##
  # Return total download count of all versions.
  
  def downloads
    versions.inject 0 do |sum, version|
      sum + version.downloads
    end
  end
  
  ##
  # Return array of version numbers.
  
  def version_numbers
    versions.map { |version| version.number }
  end
  
  ##
  # Return current version record.
  
  def current_version
    versions.first :order => [:number.desc]
  end
  
  ##
  # Return the last _version_ match in _versions_,
  # supports the following operators:
  #
  #   N/A  equal to
  #   =    equal to
  #   >    greather than
  #   >=   greather than or equal to
  #   >~   greather than or equal to with compatibility
  #
  
  def resolve version
    op, version = version.strip.split
    version, op = op, '=' unless version
    version_numbers.find do |other|
      case op
      when '='  ; other == version
      when '>'  ; other > version
      when '>=' ; other >= version
      when '>~'
        other[0..1] == version[0..1] && other >= version
      end
    end
  end
  
  #--
  # Singleton methods
  #++
  
  ##
  # Return array of all seed paths.
  
  def self.paths
    Dir[SEEDS + '/*']
  end
  
  ##
  # Return array of all seed names.
  
  def self.names
    paths.map { |path| File.basename path }
  end
  
end