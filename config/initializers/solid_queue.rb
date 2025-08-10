# frozen_string_literal: true

# Solid Queue configuration for streamlined setup
Rails.application.configure do
  # Ensure solid_queue is properly configured for development
  if Rails.env.development? && config.active_job.queue_adapter == :solid_queue
    # Log job enqueueing for development visibility
    config.active_job.verbose_enqueue_logs = true
    
    # Configure database connection for queue operations
    config.solid_queue.connects_to = {database: {writing: :queue}} if respond_to?(:solid_queue)
  end
end