# frozen_string_literal: true

require "spec_helper"

RSpec.describe Chdb::Session do
  let(:session) { described_class.new }
  let(:custom_session) { described_class.new("test_session") }
  after { session.close }

  it "creates a temporary directory when no path is specified" do
    expect(session.path).to start_with(Dir.tmpdir)
    expect(session.is_temp).to be true
  end

  it "uses the provided path when initialized" do
    expect(custom_session.path).to eq("test_session")
    expect(custom_session.is_temp).to be false
  end

  it "executes a query with the session" do
    result = session.query("SELECT 1")
    expect(result).to be_a(Chdb::LocalResult)
    expect(result.buf).not_to be_empty
  end

  it "executes a query and clean ups a temp path" do
    path = session.path
    session.query("SELECT 1")
    session.close
    expect(Dir.exist?(path)).to be false
  end

  it "does not clean up non temp directories" do
    path = custom_session.path
    custom_session.query("SELECT 1")
    custom_session.close
    expect(Dir.exist?(path)).to be true
    FileUtils.remove_entry(path) if Dir.exist?(path)
  end

  it "can execute a query with a different output format" do
    result = session.query("SELECT 1 AS a, 'test' AS b", "JSON")
    expect(result.output_format).to eq("JSON")
    expect(result.rows).to eq([{ "a" => 1, "b" => "test" }])
  end

  it "raises an error when executing a invalid query" do
    expect { session.query("SELECT invalid syntax") }.to raise_error(Chdb::Error)
  end
end
