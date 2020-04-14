require 'sidekiq-compress/compress_params'

module Sidekiq::Compress
# Should be in the client middleware chain
  class ClientMiddleware
    # Uses msg['jid'] id and puts :queued status in the job's Redis hash
    # @param [Class] worker_class if includes Sidekiq::Status::Worker, the job gets processed with the plugin
    # @param [Array] msg job arguments
    # @param [String] queue the queue's name
    # @param [ConnectionPool] redis_pool optional redis connection pool
    def call(worker, msg, queue, redis_pool)
      # return false/nil to stop the job from going to redis
      klass = msg["args"][0]["job_class"] || msg["class"] rescue msg["class"]
      job_class = klass.is_a?(Class) ? klass : Module.const_get(klass)
      unless job_class.ancestors.include?(Sidekiq::Compress)
        yield
        return
      end

      msg["args"] = Sidekiq::Compress::CompressParams.call(msg["args"])

      yield
    end
  end

  # Helper method to easily configure sidekiq-status client middleware
  # whatever the Sidekiq version is.
  # @param [Sidekiq] sidekiq_config the Sidekiq config
  # @param [Hash] client_middleware_options client middleware initialization options
  # @option client_middleware_options [Fixnum] :expiration ttl for complete jobs
  def self.configure_client_middleware(sidekiq_config)
    sidekiq_config.client_middleware do |chain|
      chain.add Sidekiq::Compress::ClientMiddleware
    end
  end
end
