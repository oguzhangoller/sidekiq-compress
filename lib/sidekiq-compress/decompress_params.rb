module Sidekiq::Compress
  class DecompressParams
    def self.call(params = [])
      result = []
      params.each do |param|
        if param.class == String
          param = Zstd.decompress(Base64.decode64(param)).force_encoding('UTF-8')
        end
        result << param
      end
      result
    end
  end
end
