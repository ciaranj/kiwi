
SEEDS = File.expand_path File.dirname(__FILE__) + '/../seeds'

module Kiwi
  class Seed
    
    ##
    # Seed name.
    
    attr_reader :name
    
    ##
    # Seed directory.
    
    attr_reader :path
    
    ##
    # Initialize with seed _name_.
    
    def initialize name
      @name = name
      @path = SEEDS + '/' + name
    end
    
    ##
    # Return array of versions available.
    
    def versions
      Dir["#{path}/*.yml"].map do |version|
        File.basename version, '.yml'
      end
    end
    
    ##
    # Load YAML info for the given _version_.
    
    def info version
      YAML.load_file path + "/#{version}.yml"
    end
    
    ##
    # Check if _version_ of this seed exists.
    
    def seed_exists? version
      File.exists? "#{path}/#{version}.seed"
    end
    
    ##
    # Transfer _version_ of this seed.
    
    def transfer version
      halt 404 unless seed_exists? version
      content_type :tar
      send_file "#{path}/#{version}.seed"
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
end