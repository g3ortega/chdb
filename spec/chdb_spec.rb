# frozen_string_literal: true

RSpec.describe Chdb do
  it "has a version number" do
    expect(Chdb::VERSION).not_to be nil
  end

  describe ".query" do
    context "with a simple query" do
      it "returns a LocalResult object" do
        result = Chdb.query("SELECT 1")
        expect(result).to be_a(Chdb::LocalResult)
      end

      it "returns a LocalResult with a buffer" do
        result = Chdb.query("SELECT 1")
        expect(result.buf).to be_a(String)
        expect(result.buf).not_to be_empty
      end

      it "returns a LocalResult with valid rows and columns" do
        result = Chdb.query("SELECT 1 AS value, 'test' AS text", "CSV")
        expect(result.rows).to eq([{ "value" => "1", "text" => "test" }])
        expect(result.columns).to eq(%w[value text])
      end
    end

    context "with an empty query" do
      it "returns a LocalResult with an empty buffer" do
        result = Chdb.query("SELECT ''")
        expect(result.buf).to be_a(String)
        expect(result.buf).not_to be_empty
      end
    end

    context "with a complex query" do
      it "returns a LocalResult with multiple rows and columns (CSV)" do
        query_str = "SELECT number, number * 2 AS double FROM numbers(5)"
        result = Chdb.query(query_str, "CSV")
        expect(result.rows).to eq([
                                    { "number" => "0", "double" => "0" },
                                    { "number" => "1", "double" => "2" },
                                    { "number" => "2", "double" => "4" },
                                    { "number" => "3", "double" => "6" },
                                    { "number" => "4", "double" => "8" }
                                  ])

        expect(result.columns).to eq(%w[number double])
      end

      it "returns a LocalResult with multiple rows and columns (JSON)" do
        query_str = "SELECT number, number * 2 AS double FROM numbers(5)"
        result = Chdb.query(query_str, "JSON")
        expect(result.rows).to eq([
                                    { "number" => 0, "double" => 0 },
                                    { "number" => 1, "double" => 2 },
                                    { "number" => 2, "double" => 4 },
                                    { "number" => 3, "double" => 6 },
                                    { "number" => 4, "double" => 8 }
                                  ])

        expect(result.columns).to eq(%w[number double])
      end
    end

    context "with invalid query" do
      it "raises a Chdb::Error" do
        expect { Chdb.query("SELECT invalid syntax") }.to raise_error(Chdb::Error)
      end
    end

    context "with different output formats" do
      it "supports CSV output format" do
        result = Chdb.query("SELECT 1 AS a, 'text' as b", "CSV")
        expect(result.output_format).to eq("CSV")
        expect(result.rows).to eq([{ "a" => "1", "b" => "text" }])
      end

      it "supports JSON output format" do
        result = Chdb.query("SELECT 1 AS a, 'text' as b", "JSON")
        expect(result.output_format).to eq("JSON")
        expect(result.rows).to eq([{ "a" => 1, "b" => "text" }])
      end
    end

    # TODO: Add debug output tests
    context "with debug output" do
      it "returns the debug output as a string" do
        result = Chdb.query("SELECT 1", "debug")
        expect(result.output_format).to eq("debug")
        expect(result.buf).to be_a(String)
        expect(result.buf).not_to be_empty
      end
    end
  end
end
