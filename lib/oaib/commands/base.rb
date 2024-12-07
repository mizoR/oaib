# frozen_string_literal: true

module Oaib
  module Commands
    #
    # Base class for commands
    #
    class Base
      class << self
        attr_reader :description

        private

        def desc(description = nil)
          @description = description if description

          @description
        end
      end

      def self.run(**)
        new(**).run
      end

      private

      def client
        OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
      end
    end
  end
end
