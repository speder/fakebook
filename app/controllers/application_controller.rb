class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init

  protected

  def init
    base_uri     = request.url.gsub(request.fullpath, '')
    timestamp    = Time.now.to_s(:ts)
    @pubsub_uri  = [base_uri, $pubsub_base_path, '/', timestamp].join
    @remote_user = request.env['REMOTE_USER']
  end
end
