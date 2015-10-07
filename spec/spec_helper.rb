ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'activefacts/api'
require 'activefacts/cql'
require 'helpers/diff_matcher'
require 'helpers/array_matcher'
require 'helpers/file_matcher'
require 'helpers/string_matcher'

# require 'helpers/compile_helpers'
# require 'helpers/parse_to_ast_matcher'
