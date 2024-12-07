# frozen_string_literal: true

RSpec.describe Oaib::CLI do
  describe ".start" do
    context "when execute the list command" do
      it do
        allow(Oaib::Commands::List).to receive(:run)

        described_class.start("list", "--after", "batch_abc123")

        expect(Oaib::Commands::List).to have_received(:run).with("--after", "batch_abc123")
      end

      it do
        get_batches_req = stub_request(:get, "https://api.openai.com/v1/batches")
                          .to_return(status: 200,
                                     body: { object: "list",
                                             data: [{ id: "batch_abc123" }, { id: "batch_def456" }],
                                             has_more: false }.to_json,
                                     headers: { "Content-type": "application/json" })

        expect { described_class.start("list") }.to output(<<~OUTPUT).to_stdout
          {"id":"batch_abc123"}
          {"id":"batch_def456"}
        OUTPUT

        expect(get_batches_req).to have_been_requested
      end
    end

    context "when execute the retrieve command" do
      it do
        allow(Oaib::Commands::Retrieve).to receive(:run)

        described_class.start("retrieve", "--batch-id", "batch_abc123")

        expect(Oaib::Commands::Retrieve).to have_received(:run).with("--batch-id", "batch_abc123")
      end
    end

    context "when execute the help command" do
      it do
        expect { described_class.start("help") }.to output(/\AUsage:/).to_stdout
      end
    end

    context "when execute the unknown command" do
      it do
        expect do
          expect { described_class.start("unknown") }.to raise_error(SystemExit)
        end.to output(/\AUsage:/).to_stdout
      end
    end
  end
end
