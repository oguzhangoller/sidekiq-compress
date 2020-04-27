module Sidekiq::Compress
  class DecompressParams
    def self.call(params = [], decompress_indexes = [])
      result = []
      if decompress_indexes.empty?
        result = decompress_all(params)
      else  
        result = decompress_by_index(params, decompress_indexes)
      end

      result
    end

    private

    def self.decompress_all(params)
      params.map! do |param|
        if param.class == String
          Zstd.decompress(Base64.decode64(param)).force_encoding('UTF-8')
        else
          param
        end
      end
    end

    def self.decompress_by_index(params, decompress_indexes)
      decompress_indexes.each do |index|
        params[index] = Zstd.decompress(Base64.decode64(params[index])).force_encoding('UTF-8')
      end

      params
    end
  end
end
