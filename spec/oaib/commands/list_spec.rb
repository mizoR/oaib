# frozen_string_literal: true

RSpec.describe Oaib::Commands::List do
  describe ".run" do
    let!(:get_batches_reqs) do
      [
        stub_request(:get, "https://api.openai.com/v1/batches")
          .to_return(status: 200,
                     body: { object: "list",
                             data: [{ id: "batch_001",
                                      input_file_id: "input_001",
                                      output_file_id: "output_001",
                                      error_file_id: "error_001" },
                                    { id: "batch_002" }],
                             has_more: true,
                             last_id: "batch_002" }.to_json,
                     headers: { "Content-type": "application/json" }),
        stub_request(:get, "https://api.openai.com/v1/batches?after=batch_002")
          .to_return(status: 200,
                     body: { object: "list",
                             data: [{ id: "batch_003" }, { id: "batch_004" }],
                             has_more: false,
                             last_id: nil }.to_json,
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
        expect { described_class.run }.to output(<<~OUTPUT).to_stdout
          {"id":"batch_001","input_file_id":"input_001","output_file_id":"output_001","error_file_id":"error_001"}
          {"id":"batch_002"}
          {"id":"batch_003"}
          {"id":"batch_004"}
        OUTPUT

        expect(get_batches_reqs).to all have_been_requested
      end
    end

    context "with --status in_progress,failed" do
      let!(:get_batches_reqs) do
        [
          stub_request(:get, "https://api.openai.com/v1/batches")
            .to_return(status: 200,
                       body: { object: "list",
                               data: [{ id: "batch_001", status: "validating" },
                                      { id: "batch_002", status: "in_progress" }],
                               has_more: true,
                               last_id: "batch_002" }.to_json,
                       headers: { "Content-type": "application/json" }),
          stub_request(:get, "https://api.openai.com/v1/batches?after=batch_002")
            .to_return(status: 200,
                       body: { object: "list",
                               data: [{ id: "batch_003", status: "completed" },
                                      { id: "batch_004", status: "failed" }],
                               has_more: false,
                               last_id: nil }.to_json,
                       headers: { "Content-type": "application/json" })
        ]
      end

      it do
        expect { described_class.run("--status", "in_progress,failed") }.to output(<<~OUTPUT).to_stdout
          {"id":"batch_002","status":"in_progress"}
          {"id":"batch_004","status":"failed"}
        OUTPUT

        expect(get_batches_reqs).to all have_been_requested
      end
    end

    context "with --after --before" do
      let!(:get_batches_reqs) do
        [
          stub_request(:get, "https://api.openai.com/v1/batches?after=batch_001")
            .to_return(status: 200,
                       body: { object: "list",
                               data: [{ id: "batch_002" }],
                               has_more: true,
                               last_id: "batch_002" }.to_json,
                       headers: { "Content-type": "application/json" }),
          stub_request(:get, "https://api.openai.com/v1/batches?after=batch_002")
            .to_return(status: 200,
                       body: { object: "list",
                               data: [{ id: "batch_003" }, { id: "batch_004" }],
                               has_more: false,
                               last_id: nil }.to_json,
                       headers: { "Content-type": "application/json" })
        ]
      end

      it do
        expect { described_class.run("--after", "batch_001", "--before", "batch_004") }.to output(<<~OUTPUT).to_stdout
          {"id":"batch_002"}
          {"id":"batch_003"}
        OUTPUT

        expect(get_batches_reqs).to all have_been_requested
      end
    end

    context "with --expand input,output,error" do
      it do
        expect { described_class.run("--expand", "input,output,error") }.to output(<<~OUTPUT).to_stdout
          {"id":"batch_001","input_file_id":"input_001","output_file_id":"output_001","error_file_id":"error_001","_input":{"id":"input_001"},"_output":{"id":"output_001"},"_error":{"id":"error_001"}}
          {"id":"batch_002","_input":null,"_output":null,"_error":null}
          {"id":"batch_003","_input":null,"_output":null,"_error":null}
          {"id":"batch_004","_input":null,"_output":null,"_error":null}
        OUTPUT

        expect(get_batches_reqs).to all have_been_requested
      end
    end
  end
end
