Delayed::Worker.sleep_delay         = 2 # seconds
Delayed::Worker.max_attempts        = 1 # don't change
Delayed::Worker.max_run_time        = 2.hours
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.logger              = Rails.logger

# because MongoDB is so insanely verbose
Delayed::Worker.logger.level = Logger::INFO

require 'job_env'
