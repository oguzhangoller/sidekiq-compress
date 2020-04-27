require 'sidekiq-compress/compress_params'

module Sidekiq::Compress
# Should be in the client middleware chain
  class ClientMiddleware
    def call(worker, msg, queue, redis_pool)
      klass = msg["args"][0]["job_class"] || msg["class"] rescue msg["class"]
      job_class = klass.is_a?(Class) ? klass : Module.const_get(klass)
      unless job_class.ancestors.include?(Sidekiq::Compress::Worker)
        yield
        return
      end

      compress_indexes = job_class.sidekiq_compress_params[0][:index] rescue []
      msg["args"] = Sidekiq::Compres::CompressParams.call(msg["args"], compress_indexes)
      yield
    end
  end

  def self.configure_client_middleware(sidekiq_config)
    sidekiq_config.client_middleware do |chain|
      chain.add Sidekiq::Compress::ClientMiddleware
    end
  end
end
