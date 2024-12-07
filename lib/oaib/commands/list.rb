# frozen_string_literal: true

module Oaib
  module Commands
    #
    # List batches
    #
    class List < Base
      desc "List your organization's batches."

      def self.run(*argv) # rubocop:disable Metrics/MethodLength
        options = {}

        OptionParser.new do |opt|
          opt.banner = "Usage: oaib list [options]"

          opt.on("--status [validating,failed,in_progress,finalizing,completed,completed]", Array) do |v|
            options[:status] = v
          end

          opt.on("--expands [input,output,error]", Array) { |v| options[:expands] = v }

          opt.on("--before [BATCH_ID]") { |v| options[:before] = v }

          opt.on("--after [BATCH_ID]") { |v| options[:after] = v }
        end.parse(argv)

        super(**options)
      end

      def initialize(status: [], expands: [], before: nil, after: nil, **)
        super()

        @loop = Loop.new(client:, status:, before:, after:)

        @expands = expands
      end

      def run
        @loop.each do |batch|
          expands.each { |key| Oaib::Commands::FileLoader.new(client:, batch:).load(key) }

          puts batch.to_json
        end
      end

      private

      attr_reader :status, :expands, :before, :after

      #
      # Loop until the batch satisfies the condition.
      #
      class Loop
        def initialize(client:, status:, before:, after:)
          @client = client
          @status = status
          @before = before
          @after = after
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength
        def each
          parameters = {}

          parameters[:after] = after if after

          catch(:done) do
            loop do
              response = client.batches.list(parameters:)

              batches = response.fetch("data")

              batches.each do |batch|
                throw(:done) if before && before == batch.fetch("id")

                next if status.size.positive? && !status.include?(batch.fetch("status"))

                yield(batch)
              end

              break unless response.fetch("has_more")

              parameters[:after] = response.fetch("last_id")
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength

        private

        attr_reader :client, :status, :before, :after
      end
    end
  end
end
