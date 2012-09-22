namespace :jobs do
  desc 'Display delayed_job environment (option: refresh=true)'
  task :env => :environment do
    job_env_path = File.join(Rails.root, 'log/job_env.yml')

    if ENV['refresh']
      puts "Deleting #{job_env_path}"
      File.unlink(job_env_path)
    end

    if File.exists?(job_env_path)
      job_env = YAML.load_file(job_env_path)
      puts(job_env.sort{ |a, b| a.first <=> b.first }.map{ |k, v| "#{k}=#{v}" }.join("\n"))
    else
      Delayed::Job.enqueue(JobEnv.new(job_env_path))
      puts "Submitted job to write environment to #{job_env_path}.\nRepeat this command to see the results."
    end
  end

  desc 'Display failed delayed_jobs'
  task :failed => :environment do
    Delayed::Job.where('failed_at is not null').each do |job|
      puts
      puts job.handler
      puts
      puts job.last_error.gsub('\\n', "\n")
      puts
    end
  end
end
