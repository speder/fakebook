# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path('../lib/basic_with_logging', __FILE__)

use Rack::ShowExceptions

$pubsub_base_path = APP_CONFIG['pubsub']['base_path'].dup
$auth             = APP_CONFIG['auth'].dup
$logger           = Logger.new('log/rack.log')
$connections      = {}

use Rack::CommonLogger, $logger

use Rack::Auth::BasicWithLogging, 'Fakebook' do |username, password|
  $auth.key?(username) && $auth[username]['password'] == password
end

app = Rack::Builder.new do
  map $pubsub_base_path do
    run PubSubApp.new
  end

  map '/' do
    run Fakebook::Application
  end
end

run app
