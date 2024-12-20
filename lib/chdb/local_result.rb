# frozen_string_literal: true

require "csv"
require "json"

module Chdb
  # Handles ClickHouse query results with support for CSV and JSON formats,
  # providing enumerable access to result rows and column information
  class LocalResult
    include Enumerable

    attr_accessor :output_format

    def to_s
      buf
    end

    def rows
      @rows ||= parse_buffer
    end

    def columns
      @columns ||= extract_columns
    end

    def each(&block)
      rows.each(&block)
    end

    private

    def parse_buffer
      return [] if buf.nil? || buf.empty?

      case output_format&.downcase
      when "csv" then parse_csv
      when "json" then parse_json
      else
        raise Chdb::Error, "Unsupported output format: #{output_format}"
      end
    end

    def parse_csv
      csv_options = { headers: true }
      CSV.parse(buf, **csv_options).map(&:to_h)
    end

    def parse_json
      parsed = JSON.parse(buf)
      parsed["data"] || []
    end

    def extract_columns
      return [] if buf.nil? || buf.empty?

      case output_format&.downcase
      when "csv" then extract_csv_columns
      when "json" then extract_json_columns
      else
        raise Chdb::Error, "Unsupported output format: #{output_format}"
      end
    end

    def extract_csv_columns
      csv_options = { headers: true }
      CSV.parse(buf, **csv_options).headers
    end

    def extract_json_columns
      first_row = parse_buffer.first
      first_row ? first_row.keys : []
    end
  end
end
