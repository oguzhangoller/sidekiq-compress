module Sidekiq::Compress
  class CompressParams
    def self.call(params = [])
      result = []
      params.each do |param|
        if param.class == String
          param = Base64.encode64(Zstd.compress(param))
        end
        result << param
      end
      result
    end
  end
end
