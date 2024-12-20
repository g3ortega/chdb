# frozen_string_literal: true

require "spec_helper"

RSpec.describe Chdb::LocalResult do
  context "when created with a valid query" do
    let(:result) { Chdb.query("SELECT 1 AS a, 'text' AS b", "CSV") }

    it "has access to the buffer" do
      expect(result.buf).to be_a(String)
      expect(result.buf).not_to be_empty
    end

    it "has access to the elapsed time" do
      expect(result.elapsed).to be_a(Float)
      expect(result.elapsed).to be >= 0
    end

    it "parses the buffer into rows" do
      expect(result.rows).to be_an(Array)
      expect(result.rows).not_to be_empty
    end

    it "extracts columns from the buffer" do
      expect(result.columns).to be_an(Array)
      expect(result.columns).not_to be_empty
    end

    it "allows iterating over rows" do
      expect { |b| result.each(&b) }.to yield_with_args({ "a" => "1", "b" => "text" })
    end
  end

  context "when created with an invalid query" do
    it "raises an error" do
      expect { Chdb.query("SELECT invalid_syntax") }.to raise_error(Chdb::Error)
    end
  end
  context "when output_format is not set" do
    it "raises an error" do
      result = Chdb.query("SELECT 1")
      result.output_format = nil
      expect { result.rows }.to raise_error(Chdb::Error, "Unsupported output format: ")
      expect { result.columns }.to raise_error(Chdb::Error, "Unsupported output format: ")
    end
  end

  context "when buf is nil or empty" do
    it "returns an empty array" do
      result = Chdb.query("SELECT ''")
      allow(result).to receive(:buf).and_return(nil)
      expect(result.rows).to eq([])
      expect(result.columns).to eq([])

      allow(result).to receive(:buf).and_return("")
      expect(result.rows).to eq([])
      expect(result.columns).to eq([])
    end
  end

  context "when the format is not supported" do
    it "raises an error" do
      result = Chdb.query("SELECT 1", "invalid")
      expect { result.rows }.to raise_error(/Unsupported output format: invalid/)
      expect { result.columns }.to raise_error(/Unsupported output format: invalid/)
    end
  end
end
