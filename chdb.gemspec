# frozen_string_literal: true

require_relative "lib/chdb/version"

Gem::Specification.new do |spec|
  spec.name = "chdb"
  spec.version = Chdb::VERSION
  spec.authors = ["Gerardo Ortega"]
  spec.email = ["g3ortega@gmail.com"]

  spec.summary = "Chdb implementation in Ruby"
  spec.description = "Ruby interface for the chDB in-process SQL OLAP Engine, " \
                    "providing direct query execution and session management capabilities."
  spec.homepage = "https://github.com/g3ortega/chdb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/g3ortega/chdb"
  spec.metadata["changelog_uri"] = "https://github.com/g3ortega/chdb/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["lib/**/*.rb", "ext/**/*.{c,h}", "ext/**/Makefile", "README.md", "LICENSE.txt", "Rakefile",
                   "chdb.gemspec"]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extensions = ["ext/chdb/extconf.rb"]
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
