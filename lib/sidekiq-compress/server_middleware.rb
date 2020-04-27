require 'sidekiq-compress/decompress_params'

module Sidekiq::Compress
  # Should be in the server middleware chain
  class ServerMiddleware
    def call(worker, msg, queue)
      klass = msg["args"][0]["job_class"] || msg["class"] rescue msg["class"]
      job_class = klass.is_a?(Class) ? klass : Module.const_get(klass)
      unless job_class.ancestors.include?(Sidekiq::Compress::Worker)
        yield
        return
      end

      decompress_indexes = job_class.sidekiq_compress_params[0][:index]

      msg["args"] = Sidekiq::Compress::DecompressParams.call(msg["args"], decompress_indexes)

      yield
    end
  end

  def self.configure_server_middleware(sidekiq_config)
    sidekiq_config.server_middleware do |chain|
      chain.add Sidekiq::Compress::ServerMiddleware
    end
  end
end
