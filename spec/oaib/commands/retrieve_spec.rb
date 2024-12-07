# frozen_string_literal: true

RSpec.describe Oaib::Commands::Retrieve do
  describe ".run" do
    let!(:get_batches_reqs) do
      [
        stub_request(:get, "https://api.openai.com/v1/batches/batch_001")
          .to_return(status: 200,
                     body: { id: "batch_001",
                             input_file_id: "input_001",
                             output_file_id: "output_001",
                             error_file_id: "error_001" }.to_json,
                     headers: { "Content-type": "application/json" })
      ]
    end

    let!(:get_file_content_reqs) do
      %w[input_001 output_001 error_001].map do |file_id|
        stub_request(:get, "https://api.openai.com/v1/files/#{file_id}/content")
          .to_return(status: 200,
                     body: { id: file_id }.to_json,
                     headers: { "Content-type": "application/json" })
      end
    end

    context "with no arguments" do
      it do
        expect { described_class.run("--batch-id", "batch_001") }.to output(<<~OUTPUT).to_stdout
          {"id":"batch_001","input_file_id":"input_001","output_file_id":"output_001","error_file_id":"error_001"}
        OUTPUT

        expect(get_batches_reqs).to all have_been_requested
      end
    end

    context "with --expand input,output,error" do
      it do
        expect do
          described_class.run("--batch-id", "batch_001", "--expand", "input,output,error")
        end.to output(<<~OUTPUT).to_stdout
          {"id":"batch_001","input_file_id":"input_001","output_file_id":"output_001","error_file_id":"error_001","_input":{"id":"input_001"},"_output":{"id":"output_001"},"_error":{"id":"error_001"}}
        OUTPUT

        expect(get_batches_reqs).to all have_been_requested

        expect(get_file_content_reqs).to all have_been_requested
      end
    end
  end
end
