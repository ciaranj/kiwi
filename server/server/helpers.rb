
helpers do
  
  ##
  # Requires and returns authentication credentials.
  
  def credentials
    auth = Rack::Auth::Basic::Request.new request.env
    fail 'http basic auth credentials required' unless auth.provided? && auth.basic?
    auth.credentials
  end
  
  ##
  # Fail with terminal-friendly _msg_. Appends ".\n".
  
  def fail msg
    error "#{msg}.\n"
  end
  
  ##
  # Require existance of _seed_ and optional _version_.
  
  def requires_seed seed, version = nil
    not_found 'seed does not exist.' unless seed.exists?
    if version
      not_found 'seed version does not exist.' unless seed.exists? version
    end
  end
  
  ##
  # Return an MD5 hash of the given _str_.
  
  def md5 str
    Digest::MD5.hexdigest str
  end
end