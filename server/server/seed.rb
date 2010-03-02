
SEEDS = ENV['KIWI_SEEDS'] || File.expand_path(File.dirname(__FILE__) + '/../seeds')

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
      end.sort
    end
    
    ##
    # Return the current version triplet.
    
    def current_version
      versions.last
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
      versions.reverse.find do |other|
        case op
        when '='  ; other == version
        when '>'  ; other > version
        when '>=' ; other >= version
        when '>~'
          other[0..1] == version[0..1] && other >= version
        end
      end
    end
    
    ##
    # Load YAML info for the given _version_.
    
    def info version
      YAML.load_file path + "/#{version}.yml"
    end
    
    ##
    # Return the path to _version_'s seed.
    
    def path_for version
      "#{path}/#{version}.seed"
    end
    
    ##
    # Check if _version_ or and versions of this seed exist.
    
    def exists? version = nil
      if version
        File.exists? path_for(version)
      else
        File.directory? path
      end
    end
    
  end
end