# ActiveJob configuration
Rails.application.configure do
  # Use async backend for development and test
  config.active_job.queue_adapter = :async

  # Set up a default queue for jobs
  config.active_job.default_queue_name = :default

  # Enable retries for failed jobs
  config.active_job.retry_jitter = 0.1
  config.active_job.retry_on_standard_error = true
end
