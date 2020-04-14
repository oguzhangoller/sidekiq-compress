require 'sidekiq-compress/decompress_params'

module Sidekiq::Compress
  # Should be in the server middleware chain
  class ServerMiddleware
    def call(worker, msg, queue)
      klass = msg["args"][0]["job_class"] || msg["class"] rescue msg["class"]
      job_class = klass.is_a?(Class) ? klass : Module.const_get(klass)
      unless job_class.ancestors.include?(Sidekiq::Compress)
        yield
        return
      end

      msg["args"] = Sidekiq::Compress::DecompressParams.call(msg["args"])

      yield
    end
  end

  # Helper method to easily configure sidekiq-status server middleware
  # whatever the Sidekiq version is.
  # @param [Sidekiq] sidekiq_config the Sidekiq config
  # @param [Hash] server_middleware_options server middleware initialization options
  # @option server_middleware_options [Fixnum] :expiration ttl for complete jobs
  def self.configure_server_middleware(sidekiq_config)
    sidekiq_config.server_middleware do |chain|
      chain.add Sidekiq::Compress::ServerMiddleware
    end
  end
end
