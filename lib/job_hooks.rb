module JobHooks
  def enqueue(job)
    log_job("enqueue")
  end

  def before(job)
    log_job("before")
  end

  def after(job)
    log_job("after")
  end

  def success(job)
    log_job("success")
  end

  def error(job, exception)
    log_job("error\nexception=#{exception.inspect}")
  end

  def failure
    log_job("failure")
  end

  def log_job(string)
    Rails.logger.info("DelayedJob [#{Time.now.to_s(:log)}] #{string}\nself=#{self.inspect}")
  end
end
