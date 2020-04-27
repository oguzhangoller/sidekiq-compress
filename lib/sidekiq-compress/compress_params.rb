module Sidekiq::Compress
  class CompressParams
    def self.call(params = [], compress_indexes = [])
      compress_indexes.empty? ? compress_all(params) : compress_by_index(params, compress_indexes)
    end

    private

    def self.compress_all(params)
      params.map! { |param| param.class == String ? Base64.encode64(Zstd.compress(param)) : param }
    end

    def self.compress_by_index(params, compress_indexes)
      compress_indexes.each do |index|
        raise "Parameter at index #{index} must be a string!" unless params[index].class == String

        params[index] = Base64.encode64(Zstd.compress(params[index]))
      end

      params
    end
  end
end
