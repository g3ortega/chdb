# frozen_string_literal: true

require_relative "chdb/version"
require "chdb/chdb"
require "chdb/local_result"
require "chdb/session"

# Ruby interface for ClickHouse database, providing direct query execution
# and session management capabilities
module Chdb
  class << self
    def query(query_str, output_format = "CSV")
      output_format ||= "CSV" # Default value
      query_to_buffer(query_str, output_format, "", "")
    end

    private

    def query_to_buffer(query_str, output_format, path, udf_path)
      argv = ["clickhouse", "--multiquery"]
      argv << "--path=#{path}" unless path.empty?
      argv << "--query=#{build_query_string(query_str, output_format)}"
      argv += udf_options(udf_path) unless udf_path.empty?

      create_result(argv, output_format)
    end

    def build_query_string(query_str, output_format)
      format_suffix = case output_format.downcase
                      when "csv" then " FORMAT CSVWithNames"
                      when "json" then " FORMAT JSON"
                      else ""
                      end
      query_str + format_suffix
    end

    def udf_options(udf_path)
      ["--", "--user_scripts_path=#{udf_path}",
       "--user_defined_executable_functions_config=#{udf_path}/*.xml"]
    end

    def create_result(argv, output_format)
      result = LocalResult.new(argv.length, argv)
      result.output_format = output_format
      result
    end
  end
end
