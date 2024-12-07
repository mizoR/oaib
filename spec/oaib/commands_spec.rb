# frozen_string_literal: true

RSpec.describe Oaib::Commands do
  describe described_class::FileLoader do
    let(:client) { instance_double(OpenAI::Client) }

    let(:files) { instance_double(OpenAI::Files) }

    context "when file_id is present" do
      it "loads files" do
        allow(client).to receive(:files).and_return(files)

        allow(files).to receive(:content).with(id: "__input_file_id__").and_return({ "id" => "__input_file_id__" })
        allow(files).to receive(:content).with(id: "__output_file_id__").and_return({ "id" => "__output_file_id__" })
        allow(files).to receive(:content).with(id: "__error_file_id__").and_return({ "id" => "__error_file_id__" })

        batch = {
          "id" => "__batch_id__",
          "input_file_id" => "__input_file_id__",
          "output_file_id" => "__output_file_id__",
          "error_file_id" => "__error_file_id__"
        }

        loader = described_class.new(client:, batch:)

        %w[input output error].each { |key| loader.load(key) }

        expect(batch).to eq(
          "id" => "__batch_id__",
          "input_file_id" => "__input_file_id__",
          "output_file_id" => "__output_file_id__",
          "error_file_id" => "__error_file_id__",
          "_input" => { "id" => "__input_file_id__" },
          "_output" => { "id" => "__output_file_id__" },
          "_error" => { "id" => "__error_file_id__" }
        )

        expect(files).to have_received(:content).exactly(3).times
      end
    end

    context "when file_id is nil" do
      it "does not load files" do
        allow(client).to receive(:files).and_return(files)

        batch = {
          "id" => "__batch_id__",
          "input_file_id" => nil,
          "output_file_id" => nil,
          "error_file_id" => nil
        }

        loader = described_class.new(client:, batch:)

        %w[input output error].each { |key| loader.load(key) }

        expect(batch).to eq(
          "id" => "__batch_id__",
          "input_file_id" => nil,
          "output_file_id" => nil,
          "error_file_id" => nil,
          "_input" => nil,
          "_output" => nil,
          "_error" => nil
        )

        expect(client).not_to receive(:files)
      end
    end
  end
end
