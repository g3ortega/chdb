# frozen_string_literal: true

require "tempfile"
require "fileutils"

module Chdb
  # Manages ClickHouse database sessions, handling temporary and permanent paths
  # for query execution and resource cleanup
  class Session
    attr_reader :path, :is_temp

    def initialize(path = nil)
      if path.nil? || path.empty?
        @path = Dir.mktmpdir("chdb_")
        @is_temp = true
      else
        @path = path
        @is_temp = false
      end
    end

    def query(query_str, output_format = "CSV")
      output_format ||= "CSV" # Default value
      query_to_buffer(query_str, output_format, @path, "")
    end

    def close
      cleanup if @is_temp && File.basename(@path).start_with?("chdb_")
    end

    def cleanup
      FileUtils.remove_entry(@path) if Dir.exist?(@path)
    end

    private

    def query_to_buffer(query_str, output_format, path, udf_path)
      argv = ["clickhouse", "--multiquery"]
      argv += format_options(output_format)
      argv << "--path=#{path}" unless path.empty?
      argv << "--query=#{query_str}"
      argv += udf_options(udf_path) unless udf_path.empty?

      create_result(argv, output_format)
    end

    def format_options(output_format)
      if output_format.casecmp("debug").zero?
        ["--verbose", "--log-level=trace", "--output-format=CSV"]
      else
        ["--output-format=#{output_format}"]
      end
    end

    def udf_options(udf_path)
      ["--", "--user_scripts_path=#{udf_path}",
       "--user_defined_executable_functions_config=#{udf_path}/*.xml"]
    end

    def create_result(argv, output_format)
      result = Chdb::LocalResult.new(argv.length, argv)
      result.output_format = output_format
      result
    end
  end
end
