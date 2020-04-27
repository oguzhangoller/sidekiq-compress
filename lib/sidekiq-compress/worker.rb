# frozen_string_literal: true

module Sidekiq::Compress
  module Worker
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :sidekiq_compress_params

      def compress_params(*params)
        @sidekiq_compress_params = params
      end
    end
  end
end
