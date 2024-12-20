# Chdb Ruby Gem

Chdb is a Ruby gem that provides a direct interface to the [chDB](https://clickhouse.com/docs/en/chdb), an in-process SQL OLAP Engine powered by ClickHouse. It allows you to execute SQL queries and manage database sessions directly from your Ruby applications.

## Status

This gem is under development and the API is not stable yet.

## Installation

First of all, you need to install the chDB engine.

**Install libchdb**

```bash
curl -sL https://lib.chdb.io | bash
```

**Install the gem**

To install the gem, add the following line to your application's Gemfile:

```ruby
gem 'chdb'
```

Then, execute:

```bash
bundle install
```

If you are not using bundler, you can install the gem by running:

1. Default installation (if chdb is in standard system paths):
   ```bash
   gem install chdb
   ```

2. Custom installation (specify chdb location):
   ```bash
   gem install chdb -- --with-opt-dir=/usr/local/lib
   ```

Make sure you have the `chdb` C library installed on your system.

## Usage

The `Chdb` gem provides two main ways to interact with the chDB engine:

1.  **Direct Query Execution:** Execute queries directly against the engine.
2.  **Session-based Query Execution:** Execute queries within a session, providing temporary storage and resource cleanup.

### Direct Query Execution

The `Chdb.query` method allows you to execute SQL queries and get results.

```ruby
require 'chdb'

# Execute a simple query
result = Chdb.query("SELECT 1")
puts result.buf # => The result as a string

# Execute a query with CSV output
result = Chdb.query("SELECT 1 AS a, 'test' AS b", "CSV")
puts result.rows # => An array of hashes with the data
puts result.columns # => The columns of the result

# Execute a query with JSON output
result = Chdb.query("SELECT 1 AS a, 'test' AS b", "JSON")
puts result.rows # => An array of hashes with the data
puts result.columns # => The columns of the result

# Handle errors
begin
    Chdb.query("SELECT invalid syntax")
rescue Chdb::Error => e
    puts "Error executing query: #{e.message}"
end
```

**Parameters:**

*   `query_str` (String): The SQL query to be executed.
*   `output_format` (String, optional): The output format for the query results, can be `"CSV"`, `"JSON"`, or `"debug"`. The default value is `"CSV"`.

**Returns:**

*   A `Chdb::LocalResult` object, containing the query results, buffer, elapsed time, rows and columns.

**Output Formats:**

*   **CSV:** Results are returned as CSV strings, parsed into an array of hashes.
*   **JSON:** Results are returned as JSON strings, parsed into an array of hashes.
*   **debug:** Results are returned as CSV format, with debug information.

### Session-based Query Execution

The `Chdb::Session` class allows you to execute queries within a session, enabling creation of temporary tables and other resources. Temporary sessions are automatically cleaned up when the session object is closed.

```ruby
require 'chdb'

# Create a new session
session = Chdb::Session.new

# Create a table
session.query("CREATE TABLE IF NOT EXISTS my_table (a Int, b String) ENGINE = Memory")

# Insert some values
session.query("INSERT INTO my_table VALUES (1, 'one'), (2, 'two')")

# Query the created table
result = session.query("SELECT * FROM my_table")
puts result.rows # => An array of hashes with the data

# Close the session. The temporary directory is cleaned
session.close

# Using a presistent path
session = Chdb::Session.new("my_persistent_db")
# ...
session.close
```

**Parameters:**

*   `path` (String, optional): The path to the database. If `nil` or empty, a temporary directory will be used, which is cleaned up when the session is closed.

**Methods:**

*   `query(query_str, output_format = "CSV")`: Executes an SQL query within the session.
    *   `query_str` (String): The SQL query to be executed.
    *   `output_format` (String, optional): The output format for the query results, can be `"CSV"`, `"JSON"`, or `"debug"`. The default value is `"CSV"`.
*   `close`: Closes the session. Cleans up the temporary directory if it was created by the session.
*   `cleanup`: Removes the session directory, it's called automatically if the session is temporal

## LocalResult Class

The `Chdb::LocalResult` class represents the result of a chDB query.

**Attributes:**

*   `buf`: The raw result buffer as a string.
*   `elapsed`: The time elapsed for the query execution.
*   `rows`: An array of hashes, representing the result rows.
*   `columns`: An array of strings representing the column names in the result.
*   `output_format`: The output format used for the query.

**Methods:**

*   `each(&block)`: Allows iteration over the rows.
*   `to_s`: Returns the buffer as a string

## Error Handling

The gem defines a custom error class `Chdb::Error`, that is raised when the chDB engine returns an error.

```ruby
begin
  Chdb.query("SELECT invalid syntax")
rescue Chdb::Error => e
  puts "Error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/g3ortega/chdb](https://github.com/g3ortega/chdb). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/g3ortega/chdb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chdb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/g3ortega/chdb/blob/main/CODE_OF_CONDUCT.md).