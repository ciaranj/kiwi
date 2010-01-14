
SEEDS = File.expand_path File.dirname(__FILE__) + '/../seeds'

helpers do
  
  ##
  # Return array of seed paths.
  
  def seed_paths
    Dir[SEEDS + '/*']
  end
  
  ##
  # Return array of versions for the given seed _name_.
  
  def seed_versions name
    Dir[SEEDS + "/#{name}/*.yml"].map do |version| 
      File.basename(version).sub('.yml', '')
    end
  end
  
  ##
  # Return array of seed names.
  
  def seed_names
    seed_paths.map { |path| File.basename path }
  end
  
  ##
  # Read yaml file for seed _name_ and _version_.
  
  def seed name, version
    YAML.load_file SEEDS + "/#{name}/#{version}.yml"
  end
  
  ##
  # Transfer seed _name_ and _version_ if it exists.
  
  def transfer_seed name, version
    path = SEEDS + "/#{name}/#{version}.seed"
    File.exists?(path) || halt(404)
    content_type :tar
    send_file path
  end
end