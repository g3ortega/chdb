# frozen_string_literal: true

require "mkmf"

# First try to find system-wide installations
system_found = have_library("chdb") && have_header("chdb.h")

unless system_found
  # Abort if not found
  abort "chdb.h or chdb library not found! Please install chdb development files"
end

# Create Makefile
create_makefile("chdb/chdb")
