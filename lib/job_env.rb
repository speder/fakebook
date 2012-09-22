class JobEnv < Struct.new(:path)
  def perform
    open(path, 'w') { |f| f.write(ENV.to_hash.to_yaml) }
  end
end
