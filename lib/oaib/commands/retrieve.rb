# frozen_string_literal: true

module Oaib
  module Commands
    #
    # Retrieve a batch
    #
    class Retrieve < Base
      desc "Retrieves a batch."

      def self.run(*argv)
        *argv = argv

        options = {}

        OptionParser.new do |opt|
          opt.banner = "Usage: oaib retrieve [options]"

          opt.on("--batch-id BATCH_ID") { |v| options[:batch_id] = v }

          opt.on("--expands [input,output,error]", Array) { |v| options[:expands] = v }
        end.parse(argv)

        super(**options)
      end

      def initialize(batch_id:, expands: [])
        super()

        @batch_id = batch_id

        @expands = expands
      end

      def run
        batch = client.batches.retrieve(id: batch_id)

        expands.each { |key| Oaib::Commands::FileLoader.new(client:, batch:).load(key) }

        puts batch.to_json
      end

      private

      attr_reader :batch_id, :expands
    end
  end
end
