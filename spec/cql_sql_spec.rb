#
# ActiveFacts tests: Parse all CQL files and check the generated SQL.
# Copyright (c) 2008 Clifford Heath. Read the LICENSE file.
#

require File.dirname(__FILE__) + '/spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/cql'
require 'activefacts/generators/sql/server'

ACTUAL_SQL_PATH = 'actual/sql/server'
FileUtils.mkdir_p(ACTUAL_SQL_PATH)

# Generate and return the SQL for the given vocabulary
def generate_sql(vocabulary)
  output = StringIO.new
  @dumper = ActiveFacts::Generators::SQL::SERVER.new(vocabulary.constellation)
  @dumper.generate(output)
  output.rewind
  output.read
end

context "CQL Loader" do

  load_failures = {
    "Airline" => "Contains unsupported queries",
    "CompanyQuery" => "Contains unsupported queries",
    "units" => "Unit verbalisation into CQL is not implemented"
  }
  generate_failures = {
    # "OrienteeringER" => "Invalid model, it just works differently in CQL"
  }

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["cql/#{pattern}.cql"]

  source_files.each do |source_file|
    base = File.basename(source_file, ".cql")
    expected_file = source_file.sub(%r{cql/(.*).cql\Z}, 'sql/server/\1.sql')
    actual_file = source_file.sub(%r{cql/(.*).cql\Z}, ACTUAL_SQL_PATH+'/\1.sql')

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

      it "should generate the expected #{actual_file}" do
	# Build and save the actual file:
	actual_text = generate_sql(vocabulary)
	File.open(actual_file, "w") { |f| f.write actual_text }
	pending("expected output file #{expected_file} not found") and next unless File.exists? expected_file
	expected_text = File.open(expected_file) {|f| f.read }

	broken = generate_failures[base]
	pending(broken) if broken

	# Discard index names:
	actual_text.gsub!(/ INDEX (\[[^\]]*\]|`[^`]*`|[^ ]*) ON /, ' INDEX <Name is hidden> ON ')
	expected_text.gsub!(/ INDEX (\[[^\]]*\]|`[^`]*`|[^ ]*) ON /, ' INDEX <Name is hidden> ON ')

	expect(actual_text).to_not differ_from(expected_text)
	if expected_text == actual_text
	  File.delete(actual_file)  # It succeeded, we don't need the file.
	end
      end
    end
  end
end
