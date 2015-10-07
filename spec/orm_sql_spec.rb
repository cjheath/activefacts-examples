#
# ActiveFacts tests: Parse all CQL files and check the generated Ruby.
# Copyright (c) 2008 Clifford Heath. Read the LICENSE file.
#

require File.dirname(__FILE__) + '/spec_helper'
require 'stringio'
require 'activefacts/metamodel'
require 'activefacts/support'
require 'activefacts/input/orm'
require 'activefacts/generators/sql/server'

ACTUAL_PATH = 'actual/orm/sql/server'
FileUtils.mkdir_p(ACTUAL_PATH)

# Generate and return the SQL for the given vocabulary
def generate(vocabulary)
  output = StringIO.new
  @dumper = ActiveFacts::Generators::SQL::SERVER.new(vocabulary.constellation)
  @dumper.generate(output)
  output.rewind
  output.read
end

context "ORM Loader" do
  load_failures = {
    "SubtypePI" => "Has an illegal uniqueness constraint",
  }
  generate_failures = {
    # "OddIdentifier" => "Strange identification pattern is incorrectly verbalised to CQL",  # Fixed
    "UnaryIdentification" => "No PI for VisitStatus",
  }

  pattern = ENV["AFTESTS"] || "*"
  source_files = Dir["orm/#{pattern}.orm"]

  source_files.each do |source_file|
    base = File.basename(source_file, ".orm")
    expected_file = 'sql/server/'+base+'.sql'
    actual_file = ACTUAL_PATH+'/'+base+'.sql'

    File.delete(actual_file) rescue nil	  # Delete if the file exists

    describe "loading #{source_file} to a model" do
      begin
        vocabulary = ActiveFacts::Input::ORM.readfile(source_file)
      rescue => e
        raise unless load_failures.include?(base)
        pending load_failures[base]
      end

      subject {vocabulary}
      it {should_not be_nil}
      vocabulary.finalise

      it "should generate the expected #{actual_file}" do
	actual_text = nil
	expect { actual_text = generate(vocabulary) }.to_not raise_error
	File.open(actual_file, "w") { |f| f.write actual_text }
	unless File.exists? expected_file
	  skip "expected output file #{expected_file} not found"
	end

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
