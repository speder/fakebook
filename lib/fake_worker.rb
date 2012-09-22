require 'job_hooks'
require 'net/http'
require 'uri'

class FakeWorker
  include JobHooks

  attr_accessor :uri, :http, :username, :password

  def initialize(pubsub_uri, remote_user)
    @uri  = URI.parse(pubsub_uri)
    @http = Net::HTTP.new(uri.host, uri.port)
    @username = remote_user
    @password = @username.present? ? $auth[remote_user]['password'] : nil
  end

  def status(options = {})
    if options.fetch(:info, false)
      pub('Info')
      exec_and_pub { Repository.info } or pub('ERROR')
    end
    pub('Status')
    exec_and_pub { Repository.status(options) } or pub('ERROR')
    close
  end

  handle_asynchronously :status

  def update(options = {})
    pub('Revert')
    exec_and_pub { Repository.revert } or pub('ERROR')
    pub('Update')
    exec_and_pub { Repository.update } or pub('ERROR')
    pub('Load documents')
    total = 0
    pub(total)
    total = Repository.create_documents(options) do |count|
      pub(count, :event => 'replace', :log => false)
    end
    pub("#{total} documents loaded", :event => 'replace')
    pub('Load tags')
    total = 0
    pub(total)
    total = Repository.create_tags(options) do |count|
      pub(count, :event => 'replace', :log => false)
    end
    pub("#{total} tags loaded", :event => 'replace')
    close
  end

  handle_asynchronously :update

  def commit(options = {})
    pub('Recreate HTML index')
    Repository.create_html_index or pub('ERROR')
    pub('Commit')
    exec_and_pub { Repository.commit(options) } or pub('ERROR')
    close
  end

  handle_asynchronously :commit

  private

  def close
    pub('End', :event => 'close')
  end

  def exec_and_pub(&block)
    output = yield
    ok = $?.success?
    output.split(/\n/).each { |line| pub(line.chomp) }
    ok
  end

  def pub(data, options = {})
    event = options.fetch(:event, 'add')
    log([event, data].join(' ')) if options.fetch(:log, true)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = "data=#{data}&event=#{event}"
    request.basic_auth username, password
    http.request(request)
  end

  def log(string)
    Rails.logger.info("#{self.class} [#{Time.now.to_s(:log)}] #{string}")
  end
end
