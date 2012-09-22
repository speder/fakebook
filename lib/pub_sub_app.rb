class PubSubApp < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  # $connections is defined in config.ru and therefore specific
  # to a particular server instance, not shared among servers
  def connections
    $connections
  end

  # Subscribe, eg:
  # GET /pubsub/1234567890
  get "/*" do |timestamp|
    content_type  "text/event-stream"
    cache_control :no_cache

    # Save subscriber connection
    # in a hash of arrays keyed by timestamp
    connections[timestamp] ||= []

    stream(:keep_open) { |out|
      connections[timestamp] << out
      log("#{timestamp} opened #{connections[timestamp].size}")
    }
  end

  # Publish, eg:
  # POST /pubsub/1234567890?&data=hello&event=add
  #
  #   Event      Subscriber action
  #
  #   add        append data
  #   replace    overwrite data
  #   close      close connection
  #
  post "/*" do |timestamp|
    event  = params[:event] || 'add'
    data   = params[:data]
    string = "event: #{event}\ndata: #{data}\n\n"
    cache_control :no_cache

    # Iterate open saved connections (subscribers) associated with timestamp
    # and publish data
    connections[timestamp].each do |out|
      out << string
      # log("#{timestamp}: #{string}")
    end

    # On 'close' event delete all saved connections associated with timestamp
    if event.to_sym == :close
      connections.delete(timestamp)
      log("#{timestamp} closed")
    end
  end

  private

  def log(string)
    $logger.info("#{self.class} [#{Time.now.to_s(:log)}] #{string}")
  end
end
