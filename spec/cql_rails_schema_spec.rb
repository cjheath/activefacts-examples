#
# ActiveFacts tests: Parse all CQL files and check the generated Rails schema.rb
# Copyright (c) 2008 Clifford Heath. Read the LICENSE file.
#

require File.dirname(__FILE__) + '/spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/cql'
require 'activefacts/generators/transform/surrogate'
require 'activefacts/generators/rails/schema'

ACTUAL_RAILS_SCHEMA_PATH = 'actual/rails/schema'
FileUtils.mkdir_p(ACTUAL_RAILS_SCHEMA_PATH)

# Generate and return the Rails models for the given vocabulary
def generate_rails_schema(vocabulary)
  output = StringIO.new
  @dumper = ActiveFacts::Generators::Rails::SchemaRb.new(vocabulary.constellation)
  @dumper.generate(output)
  output.rewind
  output.read
end

context "CQL Loader" do

  load_failures = {
    "Airline" => "Contains queries, unsupported",
    "CompanyQuery" => "Contains queries, unsupported",
    "units" => "Unit verbalisation into CQL is not implemented"
  }
  generate_failures = {
#    "Insurance" => "Misses a query in a subset constraint",
#    "OddIdentifier" => "Doesn't support identification of object fact types using mixed external/internal roles",
  }

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["cql/#{pattern}.cql"]

  source_files.each do |source_file|
    expected_file = source_file.sub(%r{cql/(.*).cql\Z}, 'rails/schema/\1.schema.rb')
    actual_file = source_file.sub(%r{cql/(.*).cql\Z}, ACTUAL_RAILS_SCHEMA_PATH+'/\1.schema.rb')

    File.delete(actual_file) rescue nil	  # Delete if the file exists
    describe "compiling #{source_file} to a model" do
      broken = load_failures[File.basename(source_file, ".cql")]
      vocabulary = nil
      if broken
        pending(broken) {
          vocabulary = ActiveFacts::Input::CQL.readfile(source_file)
        }
      else
        begin
          vocabulary = ActiveFacts::Input::CQL.readfile(source_file)
        rescue => e
          trace :exception, "#{e.message}\n" +
            "\t#{e.backtrace*"\n\t"}"
          raise
        end
      end
      subject {vocabulary}
      it {should_not be_nil}
      vocabulary.finalise

      transformer = ActiveFacts::Generators::Transform::Surrogate.new(vocabulary)
      transformer.generate(nil)

      context "and generating #{actual_file}" do
	# Build and save the actual file:
	actual_text = generate_rails_schema(vocabulary)
	File.open(actual_file, "w") { |f| f.write actual_text }
	pending("expected output file #{expected_file} not found") and next unless File.exists? expected_file
	expected_text = File.open(expected_file) {|f| f.read }

	broken = generate_failures[File.basename(actual_file, ".cql")]
	if broken
	  pending(broken) {
	    actual_text.should_not differ_from(expected_text)
	  }
	else
	  # Discard version timestamps:
	  actual_text.gsub!(/(Schema.define\(version: |# schema.rb auto-generated using ActiveFacts for .* on )[-0-9]*/, '\1')
	  expected_text.gsub!(/(Schema.define\(version: |# schema.rb auto-generated using ActiveFacts for .* on )[-0-9]*/, '\1')
	  subject { actual_text }
	  it { should_not differ_from(expected_text) }
	  if expected_text == actual_text
	    File.delete(actual_file)  # It succeeded, we don't need the file.
	  end
	end
      end
    end
  end
end
