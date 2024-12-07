# frozen_string_literal: true

#
# Example:
#
#   oaib list
#
#   oaib retrieve __BATCH_ID
#

module Oaib
  #
  # CLI for OpenAI Batch
  #
  class CLI
    class << self
      def start(*argv)
        command, *argv = argv

        klass = { list: Commands::List, retrieve: Commands::Retrieve, help: "help" }
                .fetch(command&.to_sym, nil)

        if klass.nil? || klass == "help"
          puts usage

          exit 1 if klass != "help"
        else
          klass.run(*argv)
        end
      end

      private

      def usage
        <<~USG
          Usage:
            oaib COMMAND [options]

          You must specify a command. The most common commands are:

            list      #{Commands::List.description}
            retrieve  #{Commands::Retrieve.description}
        USG
      end
    end
  end
end
