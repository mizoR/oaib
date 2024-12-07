# frozen_string_literal: true

require_relative "commands/base"
require_relative "commands/list"
require_relative "commands/retrieve"

module Oaib
  #
  # Commands
  #
  module Commands
    #
    # Load data by the file id
    #
    class FileLoader
      def initialize(client:, batch:)
        @client = client

        @batch = batch
      end

      def load(key)
        file_content_field, file_id_field = {
          "input" => %w[_input input_file_id],
          "output" => %w[_output output_file_id],
          "error" => %w[_error error_file_id]
        }.fetch(key)

        id = batch[file_id_field]

        batch[file_content_field] = id ? client.files.content(id:) : nil
      end

      private

      attr_reader :client, :batch
    end
  end
end
