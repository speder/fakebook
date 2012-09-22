module Rack
  module Auth
    class BasicWithLogging < Basic
      SKIP_LOG = /^\/(?:assets|pubsub)/

      def call(env)
        auth = Basic::Request.new(env)

        return unauthorized unless auth.provided?

        return bad_request unless auth.basic?

        conditionally_log(env, auth)

        if valid?(auth)
          env['REMOTE_USER'] = auth.username

          return @app.call(env)
        end

        unauthorized
      end

      private

      def conditionally_log(env, auth)
        username = auth.credentials.first
        password = auth.credentials.last
        address  = env['HTTP_X_REAL_IP']
        verb     = env['REQUEST_METHOD']
        path     = env['REQUEST_PATH']
        skip_log = path =~ SKIP_LOG

        if username.present? && password.present? && address.present? && !skip_log
          $logger.info("#{username}@#{address} [#{Time.now.to_s(:log)}] #{verb} #{path}")
        end
      end
    end
  end
end
